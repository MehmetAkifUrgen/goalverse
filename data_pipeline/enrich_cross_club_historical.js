const fs = require('fs');
const os = require('os');
const path = require('path');
const https = require('https');

const PROJECT_ID = 'flutterfootbalquiz';

function getFirebaseToken() {
  const p = path.join(os.homedir(), '.config/configstore/firebase-tools.json');
  if (!fs.existsSync(p)) {
    throw new Error('Firebase credentials not found.');
  }
  const c = JSON.parse(fs.readFileSync(p, 'utf8'));
  return c.tokens.access_token;
}

function downloadText(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => resolve(data));
    }).on('error', reject);
  });
}

function commitBatch(token, writes) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({ writes });
    const options = {
      hostname: 'firestore.googleapis.com',
      path: `/v1/projects/${PROJECT_ID}/databases/(default)/documents:commit`,
      method: 'POST',
      headers: {
        'Authorization': 'Bearer ' + token,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
      },
    };

    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          resolve(JSON.parse(body));
        } else {
          reject(new Error(`Commit failed (${res.statusCode}): ${body}`));
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

function sleep(ms) {
  return new Promise(r => setTimeout(r, ms));
}

function normalize(s) {
  return (s || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function generateSearchTokens(name) {
  const tokens = new Set();
  const clean = normalize(name);
  if (!clean) return [];

  tokens.add(clean);
  const words = clean.split(' ').filter(w => w.length >= 2);
  for (const w of words) {
    tokens.add(w);
    for (let len = 2; len <= w.length; len++) {
      tokens.add(w.substring(0, len));
    }
  }
  return Array.from(tokens).slice(0, 30);
}

const CLUB_MAPPING = {
  'real madrid': 'team_418',
  'real madrid cf': 'team_418',
  'fc barcelona': 'team_131',
  'barcelona': 'team_131',
  'manchester united': 'team_985',
  'man utd': 'team_985',
  'manchester utd': 'team_985',
  'ac milan': 'team_5',
  'milan': 'team_5',
  'inter milan': 'team_46',
  'inter': 'team_46',
  'internazionale': 'team_46',
  'juventus': 'team_506',
  'juventus fc': 'team_506',
  'chelsea': 'team_631',
  'chelsea fc': 'team_631',
  'arsenal': 'team_11',
  'arsenal fc': 'team_11',
  'liverpool': 'team_31',
  'liverpool fc': 'team_31',
  'manchester city': 'team_281',
  'man city': 'team_281',
  'bayern munich': 'team_27',
  'fc bayern munich': 'team_27',
  'fc bayern': 'team_27',
  'bayern': 'team_27',
  'paris saint germain': 'team_583',
  'paris sg': 'team_583',
  'psg': 'team_583',
  'atletico madrid': 'team_13',
  'atletico de madrid': 'team_13',
  'borussia dortmund': 'team_16',
  'dortmund': 'team_16',
  'tottenham': 'team_148',
  'tottenham hotspur': 'team_148',
  'as roma': 'team_12',
  'roma': 'team_12',
  'ssc napoli': 'team_6195',
  'napoli': 'team_6195',
  'ss lazio': 'team_398',
  'lazio': 'team_398',
  'galatasaray': 'team_141',
  'fenerbahce': 'team_36',
  'besiktas': 'team_114',
  'ajax': 'team_610',
  'ajax amsterdam': 'team_610',
  'fc porto': 'team_720',
  'porto': 'team_720',
  'sl benfica': 'team_294',
  'benfica': 'team_294',
  'sporting cp': 'team_336',
  'valencia': 'team_1049',
  'sevilla': 'team_368',
};

function resolveTeam(rawName) {
  if (!rawName) return null;
  const norm = normalize(rawName);
  if (CLUB_MAPPING[norm]) return CLUB_MAPPING[norm];
  const trimmed = norm.replace(/\b(fc|cf|ac|as|ss|bsc|sv|vfb|vfl|rb|sc|sk|fk|jk)\b/g, '').replace(/\s+/g, ' ').trim();
  if (CLUB_MAPPING[trimmed]) return CLUB_MAPPING[trimmed];
  return null;
}

async function main() {
  const token = getFirebaseToken();
  console.log('Firebase auth token acquired.');

  const files = [
    'premier-league.csv',
    'primera-division.csv',
    'serie-a.csv',
    '1-bundesliga.csv',
    'ligue-1.csv',
    'liga-nos.csv',
    'eredivisie.csv',
  ];

  const historicalPlayers = new Map();

  for (const f of files) {
    const text = await downloadText(`https://raw.githubusercontent.com/ewenme/transfers/master/data/${f}`);
    const lines = text.split('\n');
    const header = lines[0].split(',');
    const clubIdx = header.indexOf('club_name');
    const playerIdx = header.indexOf('player_name');
    const posIdx = header.indexOf('position');
    const involvedIdx = header.indexOf('club_involved_name');

    for (let i = 1; i < lines.length; i++) {
      const line = lines[i];
      if (!line) continue;
      const parts = line.split(',');
      const pName = parts[playerIdx]?.trim();
      const cName = parts[clubIdx]?.trim();
      const invName = parts[involvedIdx]?.trim();
      const pos = parts[posIdx]?.trim();

      const teamA = resolveTeam(cName);
      const teamB = resolveTeam(invName);

      if (pName && pName.length > 2 && (teamA || teamB)) {
        const normKey = normalize(pName);
        if (!historicalPlayers.has(normKey)) {
          historicalPlayers.set(normKey, {
            name: pName,
            position: pos || 'Forward',
            clubs: new Set(),
          });
        }
        const entry = historicalPlayers.get(normKey);
        if (teamA) entry.clubs.add(teamA);
        if (teamB) entry.clubs.add(teamB);
      }
    }
  }

  // Filter to players who played for at least 2 top target clubs (cross-club historical players)
  const multiClubPlayers = Array.from(historicalPlayers.values()).filter(p => p.clubs.size >= 2);
  console.log(`Identified ${multiClubPlayers.length} verified cross-club historical players.`);

  const writes = [];
  for (const p of multiClubPlayers) {
    const norm = normalize(p.name);
    const docId = `hist_${norm.replace(/[^a-z0-9]/g, '_')}`;
    const searchTokens = generateSearchTokens(p.name);

    writes.push({
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/players/${docId}`,
        fields: {
          id: { stringValue: docId },
          name: { stringValue: p.name },
          normalizedName: { stringValue: norm },
          position: { stringValue: p.position || 'Forward' },
          nationality: { stringValue: 'World' },
          eaFcOverall: { integerValue: '85' },
          photoUrl: { stringValue: `https://ui-avatars.com/api/?name=${encodeURIComponent(p.name)}&background=1b5e20&color=fff` },
          clubs: {
            arrayValue: {
              values: Array.from(p.clubs).map(c => ({ stringValue: c })),
            },
          },
          searchTokens: {
            arrayValue: {
              values: searchTokens.map(t => ({ stringValue: t })),
            },
          },
        },
      },
    });
  }

  console.log(`Writing ${writes.length} historical cross-club players in rate-safe chunks of 200 with pauses...`);
  const chunkSize = 200;
  for (let i = 0; i < writes.length; i += chunkSize) {
    const chunk = writes.slice(i, i + chunkSize);
    await commitBatch(token, chunk);
    console.log(`  Committed ${Math.min(i + chunk.length, writes.length)} / ${writes.length}`);
    await sleep(600); // 600ms pause to guarantee staying under Spark rate limits
  }

  console.log('🎉 Successfully saved all verified cross-club historical players to Firestore!');
}

main().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
