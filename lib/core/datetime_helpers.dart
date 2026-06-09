bool isPastDate(DateTime dt) => dt.isBefore(DateTime.now());

DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

DateTime endOfDay(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);
