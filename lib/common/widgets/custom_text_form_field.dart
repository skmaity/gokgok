// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gokgok/core/theme/app_colors.dart';

// class CustomTextFormField extends StatefulWidget {
//   final String hintText;
//   final bool obscureText;
//   final TextEditingController? controller;
//   final String? Function(String?)? validator;
//   final TextInputType? keyboardType;
//   final FocusNode? focusNode;
//   final TextInputAction? textInputAction;
//   final void Function(String)? onFieldSubmitted;

//   const CustomTextFormField({
//     super.key,
//     required this.hintText,
//     this.obscureText = false,
//     this.controller,
//     this.validator,
//     this.keyboardType,
//     this.focusNode,
//     this.textInputAction,
//     this.onFieldSubmitted,
//   });

//   @override
//   State<CustomTextFormField> createState() => _CustomTextFormFieldState();
// }

// class _CustomTextFormFieldState extends State<CustomTextFormField> {
//   late bool _isObscured;

//   @override
//   void initState() {
//     super.initState();
//     _isObscured = widget.obscureText;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20.w),
//       child: TextFormField(
//         controller: widget.controller,
//         obscureText: _isObscured,
//         validator: widget.validator,
//         keyboardType: widget.keyboardType,
//         focusNode: widget.focusNode,
//         textInputAction: widget.textInputAction,
//         onFieldSubmitted: widget.onFieldSubmitted,
//         style: const TextStyle(color: Colors.white),
//         decoration: InputDecoration(
//           hintText: widget.hintText,
//           hintStyle: const TextStyle(color: Colors.white38),
//           enabledBorder: const UnderlineInputBorder(
//             borderSide: BorderSide(color: Colors.white24),
//           ),
//           focusedBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: AppColors.primaryPink, width: 2.w),
//           ),
//           errorBorder: UnderlineInputBorder(
//             borderSide: BorderSide(
//               color: AppColors.primaryPink.withValues(alpha: 0.6),
//             ),
//           ),
//           focusedErrorBorder: UnderlineInputBorder(
//             borderSide: BorderSide(color: AppColors.primaryPink, width: 2.w),
//           ),
//           errorStyle: TextStyle(
//             color: AppColors.primaryPink,
//             fontSize: 11.sp,
//           ),
//           suffixIcon: widget.obscureText
//               ? IconButton(
//                   onPressed: () =>
//                       setState(() => _isObscured = !_isObscured),
//                   icon: Icon(
//                     _isObscured
//                         ? Icons.visibility_off_outlined
//                         : Icons.visibility_outlined,
//                     color: Colors.white38,
//                     size: 20.sp,
//                   ),
//                 )
//               : null,
//         ),
//       ),
//     );
//   }
// }
