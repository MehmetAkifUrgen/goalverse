const fs = require('fs');
const os = require('os');
const path = require('path');
const https = require('https');
const zlib = require('zlib');
const readline = require('readline');

const PROJECT_ID = 'flutterfootbalquiz';
const CLUBS_URL = 'https://pub-e682421888d945d684bcae8890b0ec20.r2.dev/data/clubs.csv.gz';
const PLAYERS_URL = 'https://pub-e682421888d945d684bcae8890b0ec20.r2.dev/data/players.csv.gz';
const TRANSFERS_URL = 'https://pub-e682421888d945d684bcae8890b0ec20.r2.dev/data/transfers.csv.gz';

const TARGET_COMPETITIONS = new Set([
  'GB1', 'ES1', 'IT1', 'L1', 'FR1', 'TR1', 'PO1', 'NL1',
  'BRA1', 'ARG1', 'SA1', 'MLS1', 'BE1', 'SC1'
]);

function getFirebaseToken() {
  const p = path.join(os.homedir(), '.config/configstore/firebase-tools.json');
  if (!fs.existsSync(p)) {
    throw new Error('Firebase credentials not found. Run firebase login first.');
  }
  const c = JSON.parse(fs.readFileSync(p, 'utf8'));
  return c.tokens.access_token;
}

function streamCsvGz(url, onRow) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'FootballApp/1.0' } }, (res) => {
      if (res.statusCode !== 200) {
        return reject(new Error(`Failed to download ${url}: status ${res.statusCode}`));
      }
      const gunzip = zlib.createGunzip();
      const rl = readline.createInterface({ input: res.pipe(gunzip), crlfDelay: Infinity });

      let headers = null;
      rl.on('line', (line) => {
        const parts = parseCsvLine(line);
        if (!headers) {
          headers = parts.map(h => h.trim().replace(/^"|"$/g, ''));
        } else {
          const row = {};
          for (let i = 0; i < headers.length; i++) {
            row[headers[i]] = (parts[i] || '').replace(/^"|"$/g, '').trim();
          }
          onRow(row);
        }
      });

      rl.on('close', () => resolve());
      rl.on('error', reject);
    }).on('error', reject);
  });
}

function parseCsvLine(text) {
  const result = [];
  let cur = '';
  let inQuotes = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (c === '"') {
      inQuotes = !inQuotes;
    } else if (c === ',' && !inQuotes) {
      result.push(cur);
      cur = '';
    } else {
      cur += c;
    }
  }
  result.push(cur);
  return result;
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
          reject(new Error(`Firestore commit failed (${res.statusCode}): ${body}`));
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

async function uploadInBatches(token, writes, batchSize = 350) {
  const total = writes.length;
  console.log(`Starting Firestore upload for ${total} documents in chunks of ${batchSize}...`);
  for (let i = 0; i < total; i += batchSize) {
    const chunk = writes.slice(i, i + batchSize);
    await commitBatch(token, chunk);
    process.stdout.write(`  Uploaded ${Math.min(i + chunk.length, total)}/${total} (${Math.round((Math.min(i + chunk.length, total)/total)*100)}%)\r`);
  }
  console.log(`\n✔ Completed upload of ${total} documents to Firestore!`);
}

function calculateOverall(marketValue, position) {
  if (marketValue >= 100000000) return 91;
  if (marketValue >= 70000000) return 88;
  if (marketValue >= 45000000) return 85;
  if (marketValue >= 25000000) return 82;
  if (marketValue >= 10000000) return 79;
  if (marketValue >= 5000000) return 76;
  if (marketValue >= 2000000) return 74;
  return 71;
}

async function main() {
  const token = getFirebaseToken();
  console.log(`[1/4] Downloading clubs across top competitions...`);

  const clubsMap = new Map();
  await streamCsvGz(CLUBS_URL, (row) => {
    const comp = row.domestic_competition_id;
    if (TARGET_COMPETITIONS.has(comp)) {
      const id = row.club_id;
      const name = row.name;
      clubsMap.set(id, {
        id: `team_${id}`,
        name: name,
        normalizedName: name.toLowerCase(),
        country: comp.substring(0, 2),
      });
    }
  });

  console.log(`Found ${clubsMap.size} clubs in target competitions.`);

  console.log(`[2/4] Downloading players...`);
  const playersList = [];
  const validPlayerIds = new Set();

  await streamCsvGz(PLAYERS_URL, (row) => {
    const currentClubId = row.current_club_id;
    if (clubsMap.has(currentClubId)) {
      const pid = row.player_id;
      const name = row.name;
      if (!name || name.length < 2) return;

      const mv = parseInt(row.market_value_in_eur || '0', 10);
      // Retain recognizable players (market value >= 1.5M EUR or key squad members)
      if (mv >= 1500000 || playersList.length < 2000) {
        validPlayerIds.add(pid);
        const overall = calculateOverall(mv, row.position);

        playersList.push({
          id: `player_${pid}`,
          name: name,
          normalizedName: name.toLowerCase(),
          nationality: row.country_of_citizenship || 'World',
          position: row.position || 'Forward',
          subPosition: row.sub_position || '',
          marketValueEuro: mv,
          eaFcOverall: overall,
          photoUrl: row.image_url || '',
          currentClubId: `team_${currentClubId}`,
        });
      }
    }
  });

  console.log(`Filtered ${playersList.length} top footballers.`);

  console.log(`[3/4] Preparing Firestore batch operations...`);

  const teamWrites = Array.from(clubsMap.values()).map((team) => ({
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/teams/${team.id}`,
      fields: {
        id: { stringValue: team.id },
        name: { stringValue: team.name },
        normalizedName: { stringValue: team.normalizedName },
        country: { stringValue: team.country },
      },
    },
  }));

  const playerWrites = playersList.map((player) => ({
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/players/${player.id}`,
      fields: {
        id: { stringValue: player.id },
        name: { stringValue: player.name },
        normalizedName: { stringValue: player.normalizedName },
        nationality: { stringValue: player.nationality },
        position: { stringValue: player.position },
        marketValueEuro: { integerValue: player.marketValueEuro.toString() },
        eaFcOverall: { integerValue: player.eaFcOverall.toString() },
        photoUrl: { stringValue: player.photoUrl },
        currentClubId: { stringValue: player.currentClubId },
      },
    },
  }));

  console.log(`[4/4] Uploading to Firestore...`);
  await uploadInBatches(token, teamWrites);
  await uploadInBatches(token, playerWrites);

  console.log(`🎉 All clubs and players successfully populated in Firestore!`);
}

main().catch((err) => {
  console.error('Error during upload:', err);
  process.exit(1);
});
