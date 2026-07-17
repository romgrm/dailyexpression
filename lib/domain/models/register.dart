/// Speech register of an expression.
enum Register {
  neutral,
  informal,
  formal;

  static Register fromCode(String code) => values.firstWhere(
        (register) => register.name == code.toLowerCase(),
        orElse: () => Register.neutral,
      );
}
