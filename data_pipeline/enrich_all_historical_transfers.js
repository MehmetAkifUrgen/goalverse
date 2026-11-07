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

async function uploadInBatches(token, writes, batchSize = 350) {
  const total = writes.length;
  console.log(`Starting Firestore commit for ${total} docs (batchSize: ${batchSize})...`);
  for (let i = 0; i < total; i += batchSize) {
    const chunk = writes.slice(i, i + batchSize);
    await commitBatch(token, chunk);
    process.stdout.write(`  Committed ${Math.min(i + chunk.length, total)}/${total} (${Math.round((Math.min(i + chunk.length, total)/total)*100)}%)\r`);
  }
  console.log(`\n✔ Successfully committed ${total} documents!`);
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

// Master club mapping
const CLUB_MAPPING = {
  // Real Madrid
  'real madrid': 'team_418',
  'real madrid cf': 'team_418',
  'real madrid castilla': 'team_418',
  'r. madrid': 'team_418',
  // Barcelona
  'fc barcelona': 'team_131',
  'barcelona': 'team_131',
  'barca': 'team_131',
  'fc barcelona b': 'team_131',
  // Man Utd
  'manchester united': 'team_985',
  'man utd': 'team_985',
  'manchester utd': 'team_985',
  'manchester u.': 'team_985',
  'man. united': 'team_985',
  // AC Milan
  'ac milan': 'team_5',
  'milan': 'team_5',
  'milan ac': 'team_5',
  // Inter Milan
  'inter milan': 'team_46',
  'inter': 'team_46',
  'internazionale': 'team_46',
  'fc internazionale': 'team_46',
  'fc inter': 'team_46',
  // Juventus
  'juventus': 'team_506',
  'juventus fc': 'team_506',
  'juve': 'team_506',
  // Chelsea
  'chelsea': 'team_631',
  'chelsea fc': 'team_631',
  // Arsenal
  'arsenal': 'team_11',
  'arsenal fc': 'team_11',
  // Liverpool
  'liverpool': 'team_31',
  'liverpool fc': 'team_31',
  // Man City
  'manchester city': 'team_281',
  'man city': 'team_281',
  'man. city': 'team_281',
  // Bayern Munich
  'bayern munich': 'team_27',
  'fc bayern munich': 'team_27',
  'fc bayern': 'team_27',
  'bayern': 'team_27',
  'bayern munchen': 'team_27',
  // PSG
  'paris saint germain': 'team_583',
  'paris saint-germain': 'team_583',
  'paris sg': 'team_583',
  'psg': 'team_583',
  // Atletico
  'atletico madrid': 'team_13',
  'atletico de madrid': 'team_13',
  'atletico': 'team_13',
  // Dortmund
  'borussia dortmund': 'team_16',
  'dortmund': 'team_16',
  'bvb': 'team_16',
  // Tottenham
  'tottenham': 'team_148',
  'tottenham hotspur': 'team_148',
  'spurs': 'team_148',
  // Roma
  'as roma': 'team_12',
  'roma': 'team_12',
  // Napoli
  'ssc napoli': 'team_6195',
  'napoli': 'team_6195',
  // Lazio
  'ss lazio': 'team_398',
  'lazio': 'team_398',
  // Galatasaray
  'galatasaray': 'team_141',
  'galatasaray sk': 'team_141',
  'galatasaray as': 'team_141',
  // Fenerbahce
  'fenerbahce': 'team_36',
  'fenerbahce sk': 'team_36',
  // Besiktas
  'besiktas': 'team_114',
  'besiktas jk': 'team_114',
  // Ajax
  'ajax': 'team_610',
  'ajax amsterdam': 'team_610',
  'afc ajax': 'team_610',
  // Porto
  'fc porto': 'team_720',
  'porto': 'team_720',
  // Benfica
  'sl benfica': 'team_294',
  'benfica': 'team_294',
  // Sporting
  'sporting cp': 'team_336',
  'sporting': 'team_336',
  'sporting lisbon': 'team_336',
  'sporting clube de portugal': 'team_336',
  // Valencia
  'valencia': 'team_1049',
  'valencia cf': 'team_1049',
  // Sevilla
  'sevilla': 'team_368',
  'sevilla fc': 'team_368',
  // Everton
  'everton': 'team_29',
  'everton fc': 'team_29',
  // Aston Villa
  'aston villa': 'team_405',
  // Newcastle
  'newcastle': 'team_762',
  'newcastle united': 'team_762',
  // West Ham
  'west ham': 'team_379',
  'west ham united': 'team_379',
  // Bayer Leverkusen
  'bayer leverkusen': 'team_15',
  'leverkusen': 'team_15',
  'bayer 04 leverkusen': 'team_15',
  // Schalke
  'schalke 04': 'team_33',
  'fc schalke 04': 'team_33',
  // Werder Bremen
  'werder bremen': 'team_86',
  // Lyon
  'olympique lyon': 'team_1041',
  'lyon': 'team_1041',
  // Marseille
  'olympique marseille': 'team_244',
  'marseille': 'team_244',
  // Monaco
  'as monaco': 'team_162',
  'monaco': 'team_162',
  // Lille
  'lille osc': 'team_1082',
  'lille': 'team_1082',
  // PSV
  'psv eindhoven': 'team_383',
  'psv': 'team_383',
  // Feyenoord
  'feyenoord rotterdam': 'team_234',
  'feyenoord': 'team_234',
};

function resolveTeam(rawName, teamsDb) {
  if (!rawName) return null;
  const norm = normalize(rawName);
  if (CLUB_MAPPING[norm]) return CLUB_MAPPING[norm];

  const trimmed = norm.replace(/\b(fc|cf|ac|as|ss|bsc|sv|vfb|vfl|rb|sc|sk|fk|jk)\b/g, '').replace(/\s+/g, ' ').trim();
  if (CLUB_MAPPING[trimmed]) return CLUB_MAPPING[trimmed];

  // Try matching against teamsDb
  if (teamsDb[norm]) return teamsDb[norm];
  if (teamsDb[trimmed]) return teamsDb[trimmed];
  return null;
}

// Iconic Football Legends Dictionary (covering 1980-2026 comprehensive career clubs)
const ICONIC_LEGENDS = [
  {
    name: 'David Beckham',
    nationality: 'England',
    position: 'Midfielder',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3139.jpg',
    clubs: ['team_985', 'team_418', 'team_5', 'team_583', 'team_1061', 'team_1030'],
  },
  {
    name: 'Zinedine Zidane',
    nationality: 'France',
    position: 'Attacking Midfielder',
    overall: 96,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3111.jpg',
    clubs: ['team_506', 'team_418', 'team_169'],
  },
  {
    name: 'Ronaldinho',
    nationality: 'Brazil',
    position: 'Attacking Midfielder',
    overall: 95,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3373.jpg',
    clubs: ['team_583', 'team_131', 'team_5'],
  },
  {
    name: 'Ronaldo Nazário',
    aliases: ['Ronaldo', 'R9', 'Ronaldo Nazario'],
    nationality: 'Brazil',
    position: 'Striker',
    overall: 96,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3140.jpg',
    clubs: ['team_383', 'team_131', 'team_46', 'team_418', 'team_5'],
  },
  {
    name: 'Cristiano Ronaldo',
    aliases: ['CR7'],
    nationality: 'Portugal',
    position: 'Striker',
    overall: 94,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/8198.jpg',
    clubs: ['team_336', 'team_985', 'team_418', 'team_506'],
  },
  {
    name: 'Lionel Messi',
    nationality: 'Argentina',
    position: 'Forward',
    overall: 94,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/28003.jpg',
    clubs: ['team_131', 'team_583', 'team_69261'],
  },
  {
    name: 'Thierry Henry',
    nationality: 'France',
    position: 'Striker',
    overall: 93,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3207.jpg',
    clubs: ['team_162', 'team_506', 'team_11', 'team_131'],
  },
  {
    name: 'Kaká',
    aliases: ['Kaka', 'Ricardo Kaka'],
    nationality: 'Brazil',
    position: 'Attacking Midfielder',
    overall: 92,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3366.jpg',
    clubs: ['team_5', 'team_418'],
  },
  {
    name: 'Clarence Seedorf',
    nationality: 'Netherlands',
    position: 'Midfielder',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3455.jpg',
    clubs: ['team_610', 'team_1038', 'team_418', 'team_46', 'team_5'],
  },
  {
    name: 'Andrea Pirlo',
    nationality: 'Italy',
    position: 'Midfielder',
    overall: 92,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/5825.jpg',
    clubs: ['team_46', 'team_5', 'team_506'],
  },
  {
    name: 'Luis Figo',
    nationality: 'Portugal',
    position: 'Winger',
    overall: 92,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3446.jpg',
    clubs: ['team_336', 'team_131', 'team_418', 'team_46'],
  },
  {
    name: 'Roberto Carlos',
    nationality: 'Brazil',
    position: 'Defender',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/7518.jpg',
    clubs: ['team_1023', 'team_46', 'team_418', 'team_36'],
  },
  {
    name: 'Rivaldo',
    nationality: 'Brazil',
    position: 'Attacking Midfielder',
    overall: 92,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3372.jpg',
    clubs: ['team_131', 'team_5'],
  },
  {
    name: 'Ruud van Nistelrooy',
    nationality: 'Netherlands',
    position: 'Striker',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3400.jpg',
    clubs: ['team_306', 'team_383', 'team_985', 'team_418', 'team_41', 'team_1084'],
  },
  {
    name: 'Michael Owen',
    nationality: 'England',
    position: 'Striker',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3109.jpg',
    clubs: ['team_31', 'team_418', 'team_762', 'team_985', 'team_512'],
  },
  {
    name: 'Wayne Rooney',
    nationality: 'England',
    position: 'Striker',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3332.jpg',
    clubs: ['team_29', 'team_985'],
  },
  {
    name: 'Robin van Persie',
    nationality: 'Netherlands',
    position: 'Striker',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/4380.jpg',
    clubs: ['team_234', 'team_11', 'team_985', 'team_36'],
  },
  {
    name: 'Zlatan Ibrahimović',
    aliases: ['Zlatan Ibrahimovic', 'Zlatan'],
    nationality: 'Sweden',
    position: 'Striker',
    overall: 92,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3455.jpg',
    clubs: ['team_610', 'team_506', 'team_46', 'team_131', 'team_5', 'team_583', 'team_985'],
  },
  {
    name: 'Frank Lampard',
    nationality: 'England',
    position: 'Midfielder',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3163.jpg',
    clubs: ['team_379', 'team_631', 'team_281'],
  },
  {
    name: 'Steven Gerrard',
    nationality: 'England',
    position: 'Midfielder',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3109.jpg',
    clubs: ['team_31'],
  },
  {
    name: 'Didier Drogba',
    nationality: 'Ivory Coast',
    position: 'Striker',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3924.jpg',
    clubs: ['team_244', 'team_631', 'team_141'],
  },
  {
    name: 'Samuel Eto\'o',
    aliases: ['Samuel Etoo', 'Etoo'],
    nationality: 'Cameroon',
    position: 'Striker',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/4257.jpg',
    clubs: ['team_418', 'team_714', 'team_237', 'team_131', 'team_46', 'team_631', 'team_29', 'team_1038'],
  },
  {
    name: 'Arjen Robben',
    nationality: 'Netherlands',
    position: 'Winger',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/4360.jpg',
    clubs: ['team_202', 'team_383', 'team_631', 'team_418', 'team_27'],
  },
  {
    name: 'Wesley Sneijder',
    nationality: 'Netherlands',
    position: 'Attacking Midfielder',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/4673.jpg',
    clubs: ['team_610', 'team_418', 'team_46', 'team_141', 'team_417'],
  },
  {
    name: 'Xabi Alonso',
    nationality: 'Spain',
    position: 'Midfielder',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/7476.jpg',
    clubs: ['team_681', 'team_31', 'team_418', 'team_27'],
  },
  {
    name: 'Patrick Vieira',
    nationality: 'France',
    position: 'Midfielder',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3183.jpg',
    clubs: ['team_5', 'team_11', 'team_506', 'team_46', 'team_281'],
  },
  {
    name: 'Edgar Davids',
    nationality: 'Netherlands',
    position: 'Midfielder',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/5758.jpg',
    clubs: ['team_610', 'team_5', 'team_506', 'team_131', 'team_46', 'team_148'],
  },
  {
    name: 'Hernán Crespo',
    aliases: ['Hernan Crespo', 'Crespo'],
    nationality: 'Argentina',
    position: 'Striker',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3410.jpg',
    clubs: ['team_398', 'team_46', 'team_631', 'team_5'],
  },
  {
    name: 'Andriy Shevchenko',
    aliases: ['Shevchenko'],
    nationality: 'Ukraine',
    position: 'Striker',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3522.jpg',
    clubs: ['team_5', 'team_631'],
  },
  {
    name: 'Michael Ballack',
    nationality: 'Germany',
    position: 'Midfielder',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/63.jpg',
    clubs: ['team_15', 'team_27', 'team_631'],
  },
  {
    name: 'Deco',
    aliases: ['Anderson Deco'],
    nationality: 'Portugal',
    position: 'Midfielder',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/8564.jpg',
    clubs: ['team_720', 'team_131', 'team_631'],
  },
  {
    name: 'Cesc Fàbregas',
    aliases: ['Cesc Fabregas', 'Fabregas'],
    nationality: 'Spain',
    position: 'Midfielder',
    overall: 88,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/8806.jpg',
    clubs: ['team_11', 'team_131', 'team_631', 'team_162', 'team_1047'],
  },
  {
    name: 'Mesut Özil',
    aliases: ['Mesut Ozil', 'Ozil'],
    nationality: 'Germany',
    position: 'Attacking Midfielder',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/35664.jpg',
    clubs: ['team_33', 'team_86', 'team_418', 'team_11', 'team_36'],
  },
  {
    name: 'Alexis Sánchez',
    aliases: ['Alexis Sanchez'],
    nationality: 'Chile',
    position: 'Forward',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/40433.jpg',
    clubs: ['team_410', 'team_131', 'team_11', 'team_985', 'team_46', 'team_244'],
  },
  {
    name: 'Ángel Di María',
    aliases: ['Angel Di Maria', 'Di Maria'],
    nationality: 'Argentina',
    position: 'Winger',
    overall: 88,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/45320.jpg',
    clubs: ['team_294', 'team_418', 'team_985', 'team_583', 'team_506'],
  },
  {
    name: 'Gonzalo Higuaín',
    aliases: ['Gonzalo Higuain', 'Higuain'],
    nationality: 'Argentina',
    position: 'Striker',
    overall: 88,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/39153.jpg',
    clubs: ['team_418', 'team_6195', 'team_506', 'team_5', 'team_631', 'team_69261'],
  },
  {
    name: 'Radamel Falcao',
    aliases: ['Falcao'],
    nationality: 'Colombia',
    position: 'Striker',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/27052.jpg',
    clubs: ['team_720', 'team_13', 'team_162', 'team_985', 'team_631', 'team_141', 'team_367'],
  },
  {
    name: 'Fernando Torres',
    aliases: ['Torres', 'El Nino'],
    nationality: 'Spain',
    position: 'Striker',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/7767.jpg',
    clubs: ['team_13', 'team_31', 'team_631', 'team_5'],
  },
  {
    name: 'Carlos Tévez',
    aliases: ['Carlos Tevez', 'Tevez'],
    nationality: 'Argentina',
    position: 'Striker',
    overall: 88,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/4276.jpg',
    clubs: ['team_379', 'team_985', 'team_281', 'team_506'],
  },
  {
    name: 'Sergio Agüero',
    aliases: ['Sergio Aguero', 'Aguero', 'Kun Aguero'],
    nationality: 'Argentina',
    position: 'Striker',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/26399.jpg',
    clubs: ['team_13', 'team_281', 'team_131'],
  },
  {
    name: 'Diego Forlán',
    aliases: ['Diego Forlan', 'Forlan'],
    nationality: 'Uruguay',
    position: 'Striker',
    overall: 88,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3408.jpg',
    clubs: ['team_985', 'team_1050', 'team_13', 'team_46'],
  },
  {
    name: 'David Villa',
    aliases: ['Villa'],
    nationality: 'Spain',
    position: 'Striker',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/7657.jpg',
    clubs: ['team_1049', 'team_131', 'team_13'],
  },
  {
    name: 'Nicolas Anelka',
    aliases: ['Anelka'],
    nationality: 'France',
    position: 'Striker',
    overall: 87,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3226.jpg',
    clubs: ['team_583', 'team_11', 'team_418', 'team_31', 'team_281', 'team_36', 'team_631', 'team_506'],
  },
  {
    name: 'Christian Panucci',
    aliases: ['Panucci'],
    nationality: 'Italy',
    position: 'Defender',
    overall: 86,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/5929.jpg',
    clubs: ['team_5', 'team_418', 'team_46', 'team_631', 'team_162', 'team_12'],
  },
  {
    name: 'Gianluca Zambrotta',
    aliases: ['Zambrotta'],
    nationality: 'Italy',
    position: 'Defender',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/5783.jpg',
    clubs: ['team_506', 'team_131', 'team_5'],
  },
  {
    name: 'Lilian Thuram',
    aliases: ['Thuram'],
    nationality: 'France',
    position: 'Defender',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3521.jpg',
    clubs: ['team_162', 'team_506', 'team_131'],
  },
  {
    name: 'Fabio Cannavaro',
    aliases: ['Cannavaro'],
    nationality: 'Italy',
    position: 'Defender',
    overall: 92,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/5775.jpg',
    clubs: ['team_6195', 'team_46', 'team_506', 'team_418'],
  },
  {
    name: 'Gheorghe Hagi',
    aliases: ['Hagi'],
    nationality: 'Romania',
    position: 'Attacking Midfielder',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/88383.jpg',
    clubs: ['team_418', 'team_131', 'team_141'],
  },
  {
    name: 'Guti',
    aliases: ['Jose Maria Gutierrez'],
    nationality: 'Spain',
    position: 'Midfielder',
    overall: 87,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/7530.jpg',
    clubs: ['team_418', 'team_114'],
  },
  {
    name: 'Ricardo Quaresma',
    aliases: ['Quaresma'],
    nationality: 'Portugal',
    position: 'Winger',
    overall: 87,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/9275.jpg',
    clubs: ['team_336', 'team_131', 'team_720', 'team_46', 'team_631', 'team_114'],
  },
  {
    name: 'Pepe',
    aliases: ['Kepler Laveran'],
    nationality: 'Portugal',
    position: 'Defender',
    overall: 88,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/14132.jpg',
    clubs: ['team_720', 'team_418', 'team_114'],
  },
  {
    name: 'Raúl González',
    aliases: ['Raul Gonzalez', 'Raul'],
    nationality: 'Spain',
    position: 'Striker',
    overall: 92,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/7331.jpg',
    clubs: ['team_418', 'team_33'],
  },
  {
    name: 'Iker Casillas',
    aliases: ['Casillas'],
    nationality: 'Spain',
    position: 'Goalkeeper',
    overall: 92,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3979.jpg',
    clubs: ['team_418', 'team_720'],
  },
  {
    name: 'Gianluigi Buffon',
    aliases: ['Buffon'],
    nationality: 'Italy',
    position: 'Goalkeeper',
    overall: 92,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/5023.jpg',
    clubs: ['team_506', 'team_583'],
  },
  {
    name: 'Alessandro Del Piero',
    aliases: ['Del Piero'],
    nationality: 'Italy',
    position: 'Forward',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/4289.jpg',
    clubs: ['team_506'],
  },
  {
    name: 'Francesco Totti',
    aliases: ['Totti'],
    nationality: 'Italy',
    position: 'Forward',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/5958.jpg',
    clubs: ['team_12'],
  },
  {
    name: 'Paolo Maldini',
    aliases: ['Maldini'],
    nationality: 'Italy',
    position: 'Defender',
    overall: 94,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/5803.jpg',
    clubs: ['team_5'],
  },
  {
    name: 'Carles Puyol',
    aliases: ['Puyol'],
    nationality: 'Spain',
    position: 'Defender',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/7594.jpg',
    clubs: ['team_131'],
  },
  {
    name: 'Xavi Hernández',
    aliases: ['Xavi Hernandez', 'Xavi'],
    nationality: 'Spain',
    position: 'Midfielder',
    overall: 93,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/7607.jpg',
    clubs: ['team_131'],
  },
  {
    name: 'Andrés Iniesta',
    aliases: ['Andres Iniesta', 'Iniesta'],
    nationality: 'Spain',
    position: 'Midfielder',
    overall: 93,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/7600.jpg',
    clubs: ['team_131'],
  },
  {
    name: 'Dani Alves',
    nationality: 'Brazil',
    position: 'Defender',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/15951.jpg',
    clubs: ['team_368', 'team_131', 'team_506', 'team_583'],
  },
  {
    name: 'Javier Mascherano',
    aliases: ['Mascherano'],
    nationality: 'Argentina',
    position: 'Defender',
    overall: 88,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/30419.jpg',
    clubs: ['team_379', 'team_31', 'team_131'],
  },
  {
    name: 'Gerard Piqué',
    aliases: ['Gerard Pique', 'Pique'],
    nationality: 'Spain',
    position: 'Defender',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/18944.jpg',
    clubs: ['team_985', 'team_131'],
  },
  {
    name: 'Sergio Ramos',
    nationality: 'Spain',
    position: 'Defender',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/24264.jpg',
    clubs: ['team_368', 'team_418', 'team_583'],
  },
  {
    name: 'Marcelo',
    nationality: 'Brazil',
    position: 'Defender',
    overall: 89,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/44501.jpg',
    clubs: ['team_418'],
  },
  {
    name: 'Karim Benzema',
    aliases: ['Benzema'],
    nationality: 'France',
    position: 'Striker',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/18922.jpg',
    clubs: ['team_1041', 'team_418'],
  },
  {
    name: 'Luka Modrić',
    aliases: ['Luka Modric', 'Modric'],
    nationality: 'Croatia',
    position: 'Midfielder',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/27974.jpg',
    clubs: ['team_148', 'team_418'],
  },
  {
    name: 'Toni Kroos',
    aliases: ['Kroos'],
    nationality: 'Germany',
    position: 'Midfielder',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/31909.jpg',
    clubs: ['team_27', 'team_15', 'team_418'],
  },
  {
    name: 'Gareth Bale',
    aliases: ['Bale'],
    nationality: 'Wales',
    position: 'Winger',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/39381.jpg',
    clubs: ['team_148', 'team_418'],
  },
  {
    name: 'Eden Hazard',
    aliases: ['Hazard'],
    nationality: 'Belgium',
    position: 'Winger',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/50202.jpg',
    clubs: ['team_1082', 'team_631', 'team_418'],
  },
  {
    name: 'Thibaut Courtois',
    aliases: ['Courtois'],
    nationality: 'Belgium',
    position: 'Goalkeeper',
    overall: 90,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/124912.jpg',
    clubs: ['team_631', 'team_13', 'team_418'],
  },
  {
    name: 'Antonio Rüdiger',
    aliases: ['Antonio Rudiger', 'Rudiger'],
    nationality: 'Germany',
    position: 'Defender',
    overall: 88,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/86202.jpg',
    clubs: ['team_12', 'team_631', 'team_418'],
  },
  {
    name: 'Mateo Kovačić',
    aliases: ['Mateo Kovacic', 'Kovacic'],
    nationality: 'Croatia',
    position: 'Midfielder',
    overall: 85,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/51471.jpg',
    clubs: ['team_46', 'team_418', 'team_631', 'team_281'],
  },
  {
    name: 'Álvaro Morata',
    aliases: ['Alvaro Morata', 'Morata'],
    nationality: 'Spain',
    position: 'Striker',
    overall: 84,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/128223.jpg',
    clubs: ['team_418', 'team_506', 'team_631', 'team_13', 'team_5'],
  },
  {
    name: 'Romelu Lukaku',
    aliases: ['Lukaku'],
    nationality: 'Belgium',
    position: 'Striker',
    overall: 86,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/96341.jpg',
    clubs: ['team_631', 'team_29', 'team_985', 'team_46', 'team_12', 'team_6195'],
  },
  {
    name: 'Pierre-Emerick Aubameyang',
    aliases: ['Aubameyang'],
    nationality: 'Gabon',
    position: 'Striker',
    overall: 85,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/58864.jpg',
    clubs: ['team_5', 'team_1082', 'team_162', 'team_16', 'team_11', 'team_131', 'team_631', 'team_244'],
  },
  {
    name: 'Edinson Cavani',
    aliases: ['Cavani'],
    nationality: 'Uruguay',
    position: 'Striker',
    overall: 87,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/48280.jpg',
    clubs: ['team_6195', 'team_583', 'team_985', 'team_1049'],
  },
  {
    name: 'Luis Suárez',
    aliases: ['Luis Suarez', 'Suarez'],
    nationality: 'Uruguay',
    position: 'Striker',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/44352.jpg',
    clubs: ['team_202', 'team_610', 'team_31', 'team_131', 'team_13', 'team_69261'],
  },
  {
    name: 'Robert Lewandowski',
    aliases: ['Lewandowski'],
    nationality: 'Poland',
    position: 'Striker',
    overall: 91,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/38253.jpg',
    clubs: ['team_16', 'team_27', 'team_131'],
  },
  {
    name: 'Miroslav Klose',
    aliases: ['Klose'],
    nationality: 'Germany',
    position: 'Striker',
    overall: 88,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/10.jpg',
    clubs: ['team_86', 'team_27', 'team_398'],
  },
  {
    name: 'Mario Balotelli',
    aliases: ['Balotelli'],
    nationality: 'Italy',
    position: 'Striker',
    overall: 85,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/45146.jpg',
    clubs: ['team_46', 'team_281', 'team_5', 'team_31', 'team_417', 'team_244'],
  },
  {
    name: 'Caner Erkin',
    nationality: 'Turkey',
    position: 'Defender',
    overall: 78,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/38531.jpg',
    clubs: ['team_141', 'team_36', 'team_46', 'team_114'],
  },
  {
    name: 'Emre Belözoğlu',
    aliases: ['Emre Belozoglu', 'Emre'],
    nationality: 'Turkey',
    position: 'Midfielder',
    overall: 84,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/5782.jpg',
    clubs: ['team_141', 'team_46', 'team_762', 'team_36', 'team_13'],
  },
  {
    name: 'Arda Turan',
    nationality: 'Turkey',
    position: 'Midfielder',
    overall: 85,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/36110.jpg',
    clubs: ['team_141', 'team_13', 'team_131'],
  },
  {
    name: 'Nihat Kahveci',
    aliases: ['Nihat'],
    nationality: 'Turkey',
    position: 'Striker',
    overall: 84,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/6934.jpg',
    clubs: ['team_114', 'team_681', 'team_1050'],
  },
  {
    name: 'Hamit Altıntop',
    aliases: ['Hamit Altintop'],
    nationality: 'Turkey',
    position: 'Midfielder',
    overall: 82,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/3592.jpg',
    clubs: ['team_33', 'team_27', 'team_418', 'team_141', 'team_105'],
  },
  {
    name: 'Nuri Şahin',
    aliases: ['Nuri Sahin'],
    nationality: 'Turkey',
    position: 'Midfielder',
    overall: 82,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/31095.jpg',
    clubs: ['team_16', 'team_234', 'team_418', 'team_31', 'team_86'],
  },
  {
    name: 'Hakan Çalhanoğlu',
    aliases: ['Hakan Calhanoglu', 'Calhanoglu'],
    nationality: 'Turkey',
    position: 'Midfielder',
    overall: 86,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/126414.jpg',
    clubs: ['team_41', 'team_15', 'team_5', 'team_46'],
  },
  {
    name: 'Cenk Tosun',
    nationality: 'Turkey',
    position: 'Striker',
    overall: 79,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/45671.jpg',
    clubs: ['team_24', 'team_114', 'team_29', 'team_36'],
  },
  {
    name: 'Burak Yılmaz',
    aliases: ['Burak Yilmaz'],
    nationality: 'Turkey',
    position: 'Striker',
    overall: 82,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/34987.jpg',
    clubs: ['team_114', 'team_36', 'team_141', 'team_1082'],
  },
  {
    name: 'Marcus Rashford',
    aliases: ['Rashford'],
    nationality: 'England',
    position: 'Forward',
    overall: 84,
    photoUrl: 'https://img.a.transfermarkt.technology/portrait/header/258027.jpg',
    clubs: ['team_985'],
  },
];

async function main() {
  const token = getFirebaseToken();
  console.log('Firebase auth token acquired.');

  const teamsDbPath = path.join(__dirname, 'firestore_teams.json');
  let teamsDb = {};
  if (fs.existsSync(teamsDbPath)) {
    teamsDb = JSON.parse(fs.readFileSync(teamsDbPath, 'utf8'));
  }

  // Build norm teamsDb
  const normTeamsDb = {};
  for (const [id, name] of Object.entries(teamsDb)) {
    normTeamsDb[normalize(name)] = id;
    const trimmed = normalize(name).replace(/\b(fc|cf|ac|as|ss|bsc|sv|vfb|vfl|rb|sc|sk|fk|jk)\b/g, '').replace(/\s+/g, ' ').trim();
    if (trimmed && trimmed.length > 2) {
      normTeamsDb[trimmed] = id;
    }
  }

  console.log(`[1/3] Downloading historical European transfers (1992-2021)...`);
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
    console.log(`  Downloading ${f}...`);
    const text = await downloadText(`https://raw.githubusercontent.com/ewenme/transfers/master/data/${f}`);
    const lines = text.split('\n');
    const header = lines[0].split(',');
    const clubIdx = header.indexOf('club_name');
    const playerIdx = header.indexOf('player_name');
    const posIdx = header.indexOf('position');
    const involvedIdx = header.indexOf('club_involved_name');
    const yearIdx = header.indexOf('year');

    for (let i = 1; i < lines.length; i++) {
      const line = lines[i];
      if (!line) continue;
      const parts = line.split(',');
      const pName = parts[playerIdx]?.trim();
      const cName = parts[clubIdx]?.trim();
      const invName = parts[involvedIdx]?.trim();
      const pos = parts[posIdx]?.trim();
      const year = parseInt(parts[yearIdx] || '0', 10);

      const teamA = resolveTeam(cName, normTeamsDb);
      const teamB = resolveTeam(invName, normTeamsDb);

      if (pName && pName.length > 2 && (teamA || teamB)) {
        const normKey = normalize(pName);
        if (!historicalPlayers.has(normKey)) {
          historicalPlayers.set(normKey, {
            name: pName,
            position: pos || 'Forward',
            clubs: new Set(),
            years: [],
          });
        }
        const entry = historicalPlayers.get(normKey);
        if (teamA) entry.clubs.add(teamA);
        if (teamB) entry.clubs.add(teamB);
        if (year) entry.years.push(year);
      }
    }
  }

  console.log(`Extracted ${historicalPlayers.size} unique players from 1992-2021 historical transfers.`);

  console.log(`[2/3] Merging curated legends and historical players into Firestore documents...`);
  const finalDocsMap = new Map();

  // 1. First add all ICONIC LEGENDS
  for (const legend of ICONIC_LEGENDS) {
    const norm = normalize(legend.name);
    // Combine with historical CSV clubs if available
    const hist = historicalPlayers.get(norm);
    const clubsSet = new Set(legend.clubs);
    if (hist) {
      for (const c of hist.clubs) clubsSet.add(c);
    }

    const docId = `legend_${norm.replace(/\s+/g, '_')}`;
    const searchTokens = generateSearchTokens(legend.name);
    if (legend.aliases) {
      for (const a of legend.aliases) {
        for (const t of generateSearchTokens(a)) searchTokens.push(t);
      }
    }

    finalDocsMap.set(docId, {
      id: docId,
      name: legend.name,
      normalizedName: norm,
      position: legend.position,
      nationality: legend.nationality,
      eaFcOverall: legend.overall,
      photoUrl: legend.photoUrl,
      clubs: Array.from(clubsSet),
      searchTokens: Array.from(new Set(searchTokens)),
    });
  }

  // 2. Add high-prominence historical players from 1992-2021 who played for 2+ clubs or top clubs
  for (const [norm, hist] of historicalPlayers.entries()) {
    if (hist.clubs.size >= 2) {
      const docId = `hist_${norm.replace(/[^a-z0-9]/g, '_')}`;
      if (!finalDocsMap.has(docId)) {
        const searchTokens = generateSearchTokens(hist.name);
        finalDocsMap.set(docId, {
          id: docId,
          name: hist.name,
          normalizedName: norm,
          position: hist.position || 'Forward',
          nationality: 'World',
          eaFcOverall: 84,
          photoUrl: `https://ui-avatars.com/api/?name=${encodeURIComponent(hist.name)}&background=1b5e20&color=fff`,
          clubs: Array.from(hist.clubs),
          searchTokens: Array.from(new Set(searchTokens)),
        });
      }
    }
  }

  console.log(`Total enriched player documents ready to commit: ${finalDocsMap.size}`);

  // Format into Firestore batch writes
  const writes = [];
  for (const doc of finalDocsMap.values()) {
    writes.push({
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/players/${doc.id}`,
        fields: {
          id: { stringValue: doc.id },
          name: { stringValue: doc.name },
          normalizedName: { stringValue: doc.normalizedName },
          position: { stringValue: doc.position },
          nationality: { stringValue: doc.nationality },
          eaFcOverall: { integerValue: doc.eaFcOverall.toString() },
          photoUrl: { stringValue: doc.photoUrl },
          clubs: {
            arrayValue: {
              values: doc.clubs.map(c => ({ stringValue: c })),
            },
          },
          searchTokens: {
            arrayValue: {
              values: doc.searchTokens.map(t => ({ stringValue: t })),
            },
          },
        },
      },
    });
  }

  console.log(`[3/3] Committing batches to Firestore...`);
  await uploadInBatches(token, writes, 350);

  console.log(`🎉 ALL historical players & legends (1980-2026) successfully synchronized in Firestore!`);
}

main().catch(err => {
  console.error('Execution failed:', err);
  process.exit(1);
});
