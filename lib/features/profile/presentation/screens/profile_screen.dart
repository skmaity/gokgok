import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gokgok/core/widgets/app_network_image.dart';
import 'package:gokgok/core/widgets/avatar_picker.dart';
import 'package:gokgok/core/widgets/submit_button.dart';
import 'package:gokgok/core/widgets/top_header_widget.dart';
import 'package:gokgok/core/theme/app_colors.dart';
import 'package:gokgok/core/theme/app_sizes.dart';
import 'package:gokgok/features/profile/presentation/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(profileScreenProvider.notifier)
          .updateProfile(fullName: _nameController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAvatarOptions() {
    showAvatarOptionsSheet(
      context,
      title: 'Change Profile Photo',
      onCamera: () => _pickAndUpload(ImageSource.camera),
      onGallery: () => _pickAndUpload(ImageSource.gallery),
      onRemove: _removeAvatar,
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final bytes = await pickAndCropAvatar(context, source: source);
    if (bytes == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      await ref
          .read(profileScreenProvider.notifier)
          .updateAvatar(bytes: bytes, fileExt: 'jpg');
      _showSnack('Profile photo updated');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _removeAvatar() async {
    setState(() => _isUploadingAvatar = true);
    try {
      await ref.read(profileScreenProvider.notifier).removeAvatar();
      _showSnack('Profile photo removed');
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final highlight = appColors.highlight;

    final profileAssync = ref.watch(profileScreenProvider);

    return Scaffold(
      body: profileAssync.when(
        data: (data) {
          // Populate once when the profile first loads. Re-running this on every
          // rebuild (e.g. keyboard animation) would wipe what the user is typing.
          if (!_controllersInitialized) {
            _nameController.text = data.name ?? '';
            _emailController.text = data.email ?? '';
            _phoneController.text = data.phoneNumber?.isNotEmpty == true
                ? data.phoneNumber!
                : 'Not provided';
            _controllersInitialized = true;
          }
          return Column(
            children: [
              MediaQuery.of(context).padding.top.verticalSpace,
              TopHeaderWidget(title: 'Profile', onPressed: () => context.pop()),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.screenPadding,
                    vertical: AppSizes.l,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _showAvatarOptions,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 104.w,
                                height: 104.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: highlight,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: highlight.withAlpha(50),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _isUploadingAvatar
                                      ? Container(
                                          color: highlight.withAlpha(25),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: highlight,
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                        )
                                      : AppNetworkImage(
                                          url: data.profileUrl,
                                          fallback: _DefaultAvatar(
                                            highlight: highlight,
                                          ),
                                        ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(
                                  color: highlight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  size: 14.w,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AppSizes.xxl.verticalSpace,
                      _ProfileField(
                        label: 'Full Name',
                        controller: _nameController,
                        icon: Icons.person_outline_rounded,
                        highlight: highlight,
                        keyboardType: TextInputType.name,
                      ),
                      AppSizes.m.verticalSpace,
                      _ProfileField(
                        label: 'Email',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        highlight: highlight,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                      ),
                      AppSizes.m.verticalSpace,
                      _ProfileField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        icon: Icons.phone_outlined,
                        highlight: highlight,
                        readOnly: true,
                      ),
                      AppSizes.xxl.verticalSpace,
                      CommounSubmitBtn(
                        label: 'Save Changes',
                        onPressed: _saveChanges,
                        isLoading: _isSaving,
                      ),
                      AppSizes.l.verticalSpace,
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        error: (e, _) => Center(child: Text('Error: $e')),
        loading: () =>
            Center(child: CircularProgressIndicator(color: highlight)),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  final Color highlight;
  const _DefaultAvatar({required this.highlight});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: highlight.withAlpha(25),
      child: Icon(Icons.person_rounded, size: 52.w, color: highlight),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Color highlight;
  final TextInputType keyboardType;
  final bool readOnly;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.highlight,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldBg = isDark
        ? Colors.white.withAlpha(10)
        : Colors.black.withAlpha(5);
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: highlight,
            letterSpacing: 0.5,
          ),
        ),
        4.verticalSpace,
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: highlight, size: 20.w),
            suffixIcon: readOnly
                ? Icon(
                    Icons.lock_outline_rounded,
                    size: 16.w,
                    color: Colors.grey,
                  )
                : Icon(
                    Icons.edit_outlined,
                    size: 16.w,
                    color: highlight.withAlpha(160),
                  ),
            filled: true,
            fillColor: readOnly ? fieldBg.withAlpha(80) : fieldBg,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.m,
              vertical: 14.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: BorderSide(color: highlight, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
      ],
    );
  }
}

