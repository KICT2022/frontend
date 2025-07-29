import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final isSeniorMode = notificationProvider.isSeniorMode;
        final fontSize = isSeniorMode ? 18.0 : 16.0;
        final titleFontSize = isSeniorMode ? 22.0 : 20.0;
        final subtitleFontSize = isSeniorMode ? 16.0 : 14.0;
        final iconSize = isSeniorMode ? 28.0 : 24.0;
        final tileHeight = isSeniorMode ? 80.0 : 70.0;
        
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              '설정',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: iconSize,
              ),
              onPressed: () => context.go('/home'),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(isSeniorMode ? 20.0 : 16.0),
            children: [
              // 시니어 UI 모드
              _buildSettingTile(
                context: context,
                title: '시니어 UI 모드',
                subtitle: '버튼과 텍스트가 더 크게 표시됩니다',
                trailing: Switch(
                  value: isSeniorMode,
                  onChanged: (value) {
                    notificationProvider.toggleSeniorMode();
                  },
                ),
                fontSize: fontSize,
                subtitleFontSize: subtitleFontSize,
                tileHeight: tileHeight,
                iconSize: iconSize,
              ),
              
              Divider(height: isSeniorMode ? 2.0 : 1.0),
              
              // 음성 안내
              _buildSettingTile(
                context: context,
                title: '음성 안내',
                subtitle: '앱 사용 시 음성으로 안내합니다',
                trailing: Switch(
                  value: notificationProvider.isVoiceEnabled,
                  onChanged: (value) {
                    notificationProvider.toggleVoiceEnabled();
                  },
                ),
                fontSize: fontSize,
                subtitleFontSize: subtitleFontSize,
                tileHeight: tileHeight,
                iconSize: iconSize,
              ),
              
              Divider(height: isSeniorMode ? 2.0 : 1.0),
              
              // 다국어 설정
              _buildSettingTile(
                context: context,
                title: '다국어 설정',
                subtitle: '현재 언어: 한국어',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: iconSize,
                ),
                onTap: () {
                  _showLanguageDialog(context, notificationProvider);
                },
                fontSize: fontSize,
                subtitleFontSize: subtitleFontSize,
                tileHeight: tileHeight,
                iconSize: iconSize,
              ),
              
              Divider(height: isSeniorMode ? 2.0 : 1.0),
              
              // 알림 설정
              _buildSettingTile(
                context: context,
                title: '알림 설정',
                subtitle: '앱 알림을 관리합니다',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: iconSize,
                ),
                onTap: () {
                  // 알림 설정 화면으로 이동
                },
                fontSize: fontSize,
                subtitleFontSize: subtitleFontSize,
                tileHeight: tileHeight,
                iconSize: iconSize,
              ),
              
              Divider(height: isSeniorMode ? 2.0 : 1.0),
              
              // 개인정보 처리방침
              _buildSettingTile(
                context: context,
                title: '개인정보 처리방침',
                subtitle: '개인정보 수집 및 이용에 대한 안내',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: iconSize,
                ),
                onTap: () {
                  // 개인정보 처리방침 화면으로 이동
                },
                fontSize: fontSize,
                subtitleFontSize: subtitleFontSize,
                tileHeight: tileHeight,
                iconSize: iconSize,
              ),
              
              Divider(height: isSeniorMode ? 2.0 : 1.0),
              
              // 이용약관
              _buildSettingTile(
                context: context,
                title: '이용약관',
                subtitle: '서비스 이용에 대한 약관',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: iconSize,
                ),
                onTap: () {
                  // 이용약관 화면으로 이동
                },
                fontSize: fontSize,
                subtitleFontSize: subtitleFontSize,
                tileHeight: tileHeight,
                iconSize: iconSize,
              ),
              
              Divider(height: isSeniorMode ? 2.0 : 1.0),
              
              // 앱 정보
              _buildSettingTile(
                context: context,
                title: '앱 정보',
                subtitle: '버전 1.0.0',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: iconSize,
                ),
                onTap: () {
                  // 앱 정보 화면으로 이동
                },
                fontSize: fontSize,
                subtitleFontSize: subtitleFontSize,
                tileHeight: tileHeight,
                iconSize: iconSize,
              ),
              
              SizedBox(height: isSeniorMode ? 50.0 : 40.0),
              
              // 로그아웃 버튼
              SizedBox(
                width: double.infinity,
                height: isSeniorMode ? 70.0 : 56.0,
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isSeniorMode ? 16.0 : 12.0),
                    ),
                  ),
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: isSeniorMode ? 20.0 : 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    required double fontSize,
    required double subtitleFontSize,
    required double tileHeight,
    required double iconSize,
  }) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final isSeniorMode = notificationProvider.isSeniorMode;
    
    return SizedBox(
      height: tileHeight,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSeniorMode ? 20.0 : 16.0,
          vertical: isSeniorMode ? 8.0 : 4.0,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, NotificationProvider provider) {
    final isSeniorMode = provider.isSeniorMode;
    final fontSize = isSeniorMode ? 18.0 : 16.0;
    final titleFontSize = isSeniorMode ? 22.0 : 20.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '언어 선택',
          style: TextStyle(fontSize: titleFontSize),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                '한국어',
                style: TextStyle(fontSize: fontSize),
              ),
              leading: Radio<String>(
                value: 'ko',
                groupValue: provider.language,
                onChanged: (value) {
                  provider.setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: Text(
                'English',
                style: TextStyle(fontSize: fontSize),
              ),
              leading: Radio<String>(
                value: 'en',
                groupValue: provider.language,
                onChanged: (value) {
                  provider.setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final isSeniorMode = notificationProvider.isSeniorMode;
    final fontSize = isSeniorMode ? 18.0 : 16.0;
    final titleFontSize = isSeniorMode ? 22.0 : 20.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '로그아웃',
          style: TextStyle(fontSize: titleFontSize),
        ),
        content: Text(
          '정말 로그아웃하시겠습니까?',
          style: TextStyle(fontSize: fontSize),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            child: Text(
              '로그아웃',
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 