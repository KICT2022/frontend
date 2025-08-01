import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/api_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = false;

  // 에러 상태 관리
  bool _emailHasError = false;
  bool _passwordHasError = false;
  String _emailErrorText = '';
  String _passwordErrorText = '';
  bool _hasAttemptedLogin = false; // 로그인 시도 여부

  // API 매니저 추가
  final ApiManager _apiManager = ApiManager();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // 이메일 유효성 검사
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // 비밀번호 유효성 검사
  bool _isValidPassword(String password) {
    // 영문 대문자 또는 소문자 중 하나라도 있고, 숫자를 포함한 8자 이상
    final passwordRegex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  // 이메일 필드 검증
  void _validateEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailHasError = true;
        _emailErrorText = '이메일을 입력해주세요.';
      });
    } else if (!_isValidEmail(email)) {
      setState(() {
        _emailHasError = true;
        _emailErrorText = '올바른 이메일 형식을 입력해주세요. (예: user@domain.com)';
      });
    } else {
      setState(() {
        _emailHasError = false;
        _emailErrorText = '';
      });
    }
  }

  // 비밀번호 필드 검증
  void _validatePassword() {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _passwordHasError = true;
        _passwordErrorText = '비밀번호를 입력해주세요.';
      });
    } else if (!_isValidPassword(password)) {
      setState(() {
        _passwordHasError = true;
        _passwordErrorText = '비밀번호는 영문자와 숫자를 포함한 8자 이상이어야 합니다.';
      });
    } else {
      setState(() {
        _passwordHasError = false;
        _passwordErrorText = '';
      });
    }
  }

  Future<void> _login() async {
    // 로그인 시도 플래그 설정
    setState(() {
      _hasAttemptedLogin = true;
      _isLoading = true;
    });

    // 모든 필드 검증
    _validateEmail();
    _validatePassword();

    // 에러가 있으면 로그인 시도하지 않음
    if (_emailHasError || _passwordHasError) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      print('🔍 로그인 시도: email=${_emailController.text.trim()}');

      // API 매니저를 통한 직접 로그인 시도
      final result = await _apiManager.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('📡 로그인 결과: success=${result.success}, error=${result.error}');
      if (result.user != null) {
        print('👤 사용자 정보: ${result.user!.name}, ${result.user!.email}');
      }

      if (result.success && result.user != null) {
        // AuthProvider에도 사용자 정보 설정
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.setCurrentUser(result.user!);

        if (mounted) {
          context.go('/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? '로그인에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // 앱 아이콘
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                  ),
                  child: Icon(
                    Icons.medication,
                    size: 60,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // 앱 이름
                const Text(
                  '방구석 약사',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '언제 어디서나 건강한 복약 관리',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 50),

                // 이메일 입력
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    _passwordFocusNode.requestFocus();
                  },
                  decoration: InputDecoration(
                    labelText: '이메일',
                    prefixIcon: const Icon(Icons.email),
                    hintText: 'example@email.com',
                    errorText:
                        _hasAttemptedLogin && _emailHasError
                            ? _emailErrorText
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _hasAttemptedLogin && _emailHasError
                                ? Colors.red
                                : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _hasAttemptedLogin && _emailHasError
                                ? Colors.red
                                : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _hasAttemptedLogin && _emailHasError
                                ? Colors.red
                                : Colors.blue,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 비밀번호 입력
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    // 자동 로그인 방지 - 로그인 버튼을 직접 클릭해야만 실행
                    // 포커스만 해제
                  },
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    hintText: '영문자, 숫자 포함 8자 이상',
                    errorText:
                        _hasAttemptedLogin && _passwordHasError
                            ? _passwordErrorText
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _hasAttemptedLogin && _passwordHasError
                                ? Colors.red
                                : Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _hasAttemptedLogin && _passwordHasError
                                ? Colors.red
                                : Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color:
                            _hasAttemptedLogin && _passwordHasError
                                ? Colors.red
                                : Colors.blue,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              '로그인',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),

                // 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.go('/register'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 아이디/비밀번호 찾기
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        // 아이디 찾기 기능
                      },
                      child: Text(
                        '아이디 찾기',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Text(' | ', style: TextStyle(color: Colors.grey.shade400)),
                    TextButton(
                      onPressed: () {
                        // 비밀번호 찾기 기능
                      },
                      child: Text(
                        '비밀번호 찾기',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
