import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/medication_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/bottom_navigation.dart';
import 'search_screen.dart';
import 'medication_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // 약간의 지연 후 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final medicationProvider = Provider.of<MedicationProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      
      await medicationProvider.loadMedications();
      await notificationProvider.loadSettings();
    } catch (e) {
      // 오류 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final isSeniorMode = notificationProvider.isSeniorMode;
        final fontSize = isSeniorMode ? 18.0 : 16.0;
        final titleFontSize = isSeniorMode ? 24.0 : 20.0;
        final subtitleFontSize = isSeniorMode ? 16.0 : 14.0;
        final iconSize = isSeniorMode ? 32.0 : 24.0;
        final cardPadding = isSeniorMode ? 20.0 : 16.0;
        final cardRadius = isSeniorMode ? 16.0 : 12.0;
        
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                // 헤더
                Container(
                  padding: EdgeInsets.all(isSeniorMode ? 20.0 : 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.medication,
                        size: iconSize,
                        color: Colors.blue.shade600,
                      ),
                      SizedBox(width: isSeniorMode ? 16.0 : 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '방구석 약사',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '언제 어디서나 건강한 복약 관리',
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 메인 콘텐츠
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isSeniorMode ? 20.0 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 오늘의 복용 약물
                        Container(
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(cardRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.today,
                                    size: iconSize,
                                    color: Colors.blue.shade600,
                                  ),
                                  SizedBox(width: isSeniorMode ? 12.0 : 8.0),
                                  Text(
                                    '오늘의 복용 약물',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isSeniorMode ? 16.0 : 12.0),
                              Consumer<MedicationProvider>(
                                builder: (context, medicationProvider, child) {
                                  final todayMedications = medicationProvider.medications.take(3).toList();
                                  return Column(
                                    children: todayMedications.map((medication) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: isSeniorMode ? 8.0 : 4.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.medication,
                                              size: isSeniorMode ? 24.0 : 20.0,
                                              color: Colors.grey.shade600,
                                            ),
                                            SizedBox(width: isSeniorMode ? 12.0 : 8.0),
                                            Expanded(
                                              child: Text(
                                                medication.name,
                                                style: TextStyle(fontSize: subtitleFontSize),
                                              ),
                                            ),
                                            Text(
                                              '${medication.dosage}',
                                              style: TextStyle(
                                                fontSize: subtitleFontSize,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isSeniorMode ? 24.0 : 20.0),
                        
                        // 주간 복용 달성률
                        Container(
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(cardRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    size: iconSize,
                                    color: Colors.green.shade600,
                                  ),
                                  SizedBox(width: isSeniorMode ? 12.0 : 8.0),
                                  Text(
                                    '주간 복용 달성률',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isSeniorMode ? 16.0 : 12.0),
                              _buildAchievementItem('월', 85, isSeniorMode, subtitleFontSize),
                              _buildAchievementItem('화', 92, isSeniorMode, subtitleFontSize),
                              _buildAchievementItem('수', 78, isSeniorMode, subtitleFontSize),
                              _buildAchievementItem('목', 95, isSeniorMode, subtitleFontSize),
                              _buildAchievementItem('금', 88, isSeniorMode, subtitleFontSize),
                              _buildAchievementItem('토', 90, isSeniorMode, subtitleFontSize),
                              _buildAchievementItem('일', 82, isSeniorMode, subtitleFontSize),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isSeniorMode ? 24.0 : 20.0),
                        
                        // 메뉴 그리드
                        Text(
                          '서비스 메뉴',
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isSeniorMode ? 16.0 : 12.0),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: isSeniorMode ? 16.0 : 12.0,
                          mainAxisSpacing: isSeniorMode ? 16.0 : 12.0,
                          childAspectRatio: isSeniorMode ? 1.2 : 1.1,
                          children: [
                            _buildMenuCard(
                              context,
                              '약물 검색',
                              Icons.search,
                              Colors.blue,
                              '/search',
                              isSeniorMode,
                              fontSize,
                              iconSize,
                            ),
                            _buildMenuCard(
                              context,
                              '복용 관리',
                              Icons.medication,
                              Colors.green,
                              '/medication',
                              isSeniorMode,
                              fontSize,
                              iconSize,
                            ),
                            _buildMenuCard(
                              context,
                              '프로필',
                              Icons.person,
                              Colors.orange,
                              '/profile',
                              isSeniorMode,
                              fontSize,
                              iconSize,
                            ),
                            _buildMenuCard(
                              context,
                              '설정',
                              Icons.settings,
                              Colors.purple,
                              '/settings',
                              isSeniorMode,
                              fontSize,
                              iconSize,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigation(
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  // 이미 홈 화면
                  break;
                case 1:
                  context.go('/search');
                  break;
                case 2:
                  context.go('/medication');
                  break;
                case 3:
                  context.go('/profile');
                  break;
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildAchievementItem(String day, int percentage, bool isSeniorMode, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSeniorMode ? 6.0 : 4.0),
      child: Row(
        children: [
          SizedBox(
            width: isSeniorMode ? 40.0 : 30.0,
            child: Text(
              day,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: isSeniorMode ? 12.0 : 8.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(isSeniorMode ? 6.0 : 4.0),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(isSeniorMode ? 6.0 : 4.0),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: isSeniorMode ? 12.0 : 8.0),
          SizedBox(
            width: isSeniorMode ? 40.0 : 30.0,
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
    bool isSeniorMode,
    double fontSize,
    double iconSize,
  ) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: EdgeInsets.all(isSeniorMode ? 20.0 : 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSeniorMode ? 16.0 : 12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSeniorMode ? 16.0 : 12.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isSeniorMode ? 12.0 : 8.0),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: color,
              ),
            ),
            SizedBox(height: isSeniorMode ? 12.0 : 8.0),
            Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 