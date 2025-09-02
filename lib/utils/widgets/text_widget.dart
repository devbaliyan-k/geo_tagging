import '../app_imports/app_imports.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final FontWeight? fontWeight;
  final double? fontSize;
  final Color? color;
  final FontStyle? fontStyle;
  const TextWidget({
    super.key,
    required this.text,
    this.fontWeight,
    this.fontSize,
    this.color,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: fontWeight ?? FontWeight.normal,
        fontSize: fontSize ?? 20,
        color: color ?? AppColor.blackColor,
        fontStyle: fontStyle ?? FontStyle.normal,

      ),
    );
  }
}
