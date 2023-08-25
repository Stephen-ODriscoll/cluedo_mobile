
enum Status {
  okay,
  infoNeeded,
  contradiction,
  exception
}

enum Action {
  missed,
  asked,
  guessed
}

enum Conviction {
  unknown,
  innocent,
  guilty
}

enum Finding {
  has,
  hasEither,
  doesNotHave,
  guessedWrong,
  allCardsKnown,
  innocent,
  guilty
}
