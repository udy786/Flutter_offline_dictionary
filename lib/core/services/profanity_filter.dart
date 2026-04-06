/// Filters offensive/vulgar words from search results.
/// Used to maintain 4+ age rating on App Store.
class ProfanityFilter {
  ProfanityFilter._();

  static final ProfanityFilter instance = ProfanityFilter._();

  /// Set of offensive root words (lowercase)
  static const Set<String> _blockedWords = {
    // English profanity
    'fuck', 'fucking', 'fucker', 'fucked', 'fucks',
    'fuckbook', 'fuckerberg', 'fuckface', 'fuckhead',
    'fuckwit', 'motherfucker', 'motherfucking',
    'shit', 'shitting', 'shitty', 'shithead', 'bullshit',
    'ass', 'asshole', 'arsehole', 'arse',
    'bitch', 'bitches', 'bitchy',
    'damn', 'damned', 'goddamn',
    'bastard', 'bastards',
    'dick', 'dickhead',
    'cock', 'cocks', 'cocksucker',
    'cunt', 'cunts',
    'piss', 'pissed', 'pissing',
    'whore', 'whores',
    'slut', 'sluts', 'slutty',
    'wanker', 'wanking',
    'twat',
    'nigger', 'nigga', 'niggas',
    'faggot', 'fag', 'fags',
    'retard', 'retarded',
    'pussy',
    'dildo', 'dildos',
    'blowjob',
    'handjob',
    'jerkoff',
    'jackoff',
    'orgasm',
    'masturbate', 'masturbation',
    'penis',
    'vagina',
    'clitoris',
    'ejaculate', 'ejaculation',
    'porn', 'porno', 'pornography',
    'hentai',
    'xxx',
    'anal',
    'cum', 'cumshot',
    'boob', 'boobs', 'tits', 'titties',
    'erection',
    'nude', 'nudes', 'nudity',
    'horny',
    'sexy',
    'buttfuck',
    'deepthroat',
    'gangbang',
    'threesome',
    'foursome',
    'rimjob',
    'sodomy',
    'fellatio',
    'cunnilingus',

    // Hindi profanity (transliterated)
    'chutiya', 'chutiye', 'chutia',
    'madarchod', 'madarchodh',
    'bhenchod', 'behenchod', 'bhosdike',
    'gaand', 'gand', 'gaandu',
    'lund', 'lauda', 'laude',
    'randi', 'raand',
    'harami', 'haramkhor',
    'chod', 'chodna',
    'chudai',
  };

  /// Check if a word is offensive
  bool isOffensive(String word) {
    final lower = word.toLowerCase().trim();

    // Exact match
    if (_blockedWords.contains(lower)) return true;

    // Check if the word starts with a blocked word
    // (catches variations like "fucking", "fuckers", etc.)
    for (final blocked in _blockedWords) {
      if (lower.startsWith(blocked) && lower.length <= blocked.length + 4) {
        return true;
      }
    }

    return false;
  }

  /// Check if a search query itself is offensive
  bool isQueryOffensive(String query) {
    final lower = query.toLowerCase().trim();
    return _blockedWords.contains(lower);
  }
}
