import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/api_manager.dart';
import 'dart:async';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _verificationCodeFocusNode = FocusNode();

  String _selectedGender = '남';
  DateTime _selectedDate = DateTime(2003, 12, 22);
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isEmailVerified = false;
  bool _isVerificationCodeSent = false;
  int _countdown = 0;
  Timer? _timer;

  // API 매니저 추가
  final ApiManager _apiManager = ApiManager();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _verificationCodeFocusNode.dispose();

    _timer?.cancel();
    super.dispose();
  }

  // 이메일 인증 코드 전송
  Future<void> _sendVerificationCode() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 이메일을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // API 매니저를 통한 인증 코드 전송
      final result = await _apiManager.sendVerificationCode(
        _emailController.text.trim(),
      );

      if (result.success) {
        setState(() {
          _isVerificationCodeSent = true;
          _countdown = 180; // 3분 카운트다운
        });

        // 카운트다운 타이머 시작
        _startCountdown();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.message ?? '인증 코드가 ${_emailController.text}로 전송되었습니다.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? '인증 코드 전송에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('인증 코드 전송 중 오류가 발생했습니다: $e'),
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

  // 인증 코드 확인
  Future<void> _verifyCode() async {
    // 입력된 인증 코드 검증
    final inputCode = _verificationCodeController.text.trim();

    if (inputCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('인증 코드를 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 6자리 숫자 형식 검증
    if (inputCode.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(inputCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('6자리 숫자로 된 인증 코드를 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔍 인증 코드 확인 요청: ${_emailController.text.trim()} / $inputCode');

      // 매번 서버에 새로운 인증 코드 확인 요청
      final result = await _apiManager.verifyCode(
        _emailController.text.trim(),
        inputCode,
      );

      print(
        '📡 인증 결과: success=${result.success}, message=${result.message}, error=${result.error}',
      );

      if (result.success) {
        // 서버에서 인증 성공 응답을 받은 경우에만 인증 완료 처리
        setState(() {
          _isEmailVerified = true;
        });
        _timer?.cancel();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? '이메일 인증이 완료되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 서버에서 인증 실패 응답을 받은 경우
        // 인증 상태를 false로 설정하여 재시도 가능하도록 함
        setState(() {
          _isEmailVerified = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? '인증 코드가 일치하지 않습니다. 다시 확인해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ 인증 코드 확인 중 오류: $e');

      // 오류 발생 시 인증 상태를 false로 설정
      setState(() {
        _isEmailVerified = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('인증 코드 확인 중 오류가 발생했습니다: $e'),
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

  // 카운트다운 타이머 시작
  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
          // 카운트다운이 끝나면 인증 상태 초기화
          _isVerificationCodeSent = false;
          _isEmailVerified = false;
          _verificationCodeController.clear();
        }
      });
    });
  }

  // 인증 코드 재전송
  Future<void> _resendVerificationCode() async {
    // 기존 인증 상태 초기화
    setState(() {
      _isEmailVerified = false;
      _verificationCodeController.clear();
    });

    // 타이머 취소
    _timer?.cancel();

    // 새로운 인증 코드 전송
    await _sendVerificationCode();
  }

  Future<void> _register() async {
    // 폼 검증
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 필수 항목을 올바르게 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 이메일 인증 완료 확인
    if (!_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이메일 인증을 완료해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 인증 코드가 전송되지 않았거나 만료된 경우
    if (!_isVerificationCodeSent || _countdown <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('유효한 인증 코드를 먼저 전송해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // API 매니저를 통한 직접 회원가입 시도
      final result = await _apiManager.signup(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirm: _confirmPasswordController.text,
        gender: _selectedGender,
        birthDate:
            _selectedDate.toIso8601String().split('T')[0], // YYYY-MM-DD 형식
        phoneNumber: _phoneController.text,
      );

      if (result.success) {
        if (result.user != null) {
          // AuthProvider에도 사용자 정보 설정
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          authProvider.setCurrentUser(result.user!);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? '회원가입이 완료되었습니다.'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? '회원가입에 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입 중 오류가 발생했습니다: $e'),
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 앱 아이콘과 제목
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.medication,
                          size: 50,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '방구석 약사',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '언제 어디서나 건강한 복약 관리',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 이름 입력
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    _phoneFocusNode.requestFocus();
                  },
                  decoration: InputDecoration(
                    labelText: '이름',
                    prefixIcon: const Icon(Icons.person),
                    hintText: '홍길동',
                    errorStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.shade400,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 성별 선택
                Row(
                  children: [
                    const Text('성별: ', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 20),
                    ChoiceChip(
                      label: const Text('남'),
                      selected: _selectedGender == '남',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedGender = '남';
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('여'),
                      selected: _selectedGender == '여',
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedGender = '여';
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 생년월일 선택
                Row(
                  children: [
                    const Text('생년월일: ', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _selectDate,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 전화번호 입력
                TextFormField(
                  controller: _phoneController,
                  focusNode: _phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    _emailFocusNode.requestFocus();
                  },
                  decoration: InputDecoration(
                    labelText: '전화번호',
                    prefixIcon: const Icon(Icons.phone),
                    hintText: '01012345678 (하이픈 제외)',
                    errorStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.shade400,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '전화번호를 입력해주세요.';
                    }
                    // 하이픈 제거
                    final cleanNumber = value.replaceAll('-', '');
                    if (cleanNumber.length != 11) {
                      return '전화번호는 11자리여야 합니다.';
                    }
                    if (!cleanNumber.startsWith('010') &&
                        !cleanNumber.startsWith('011') &&
                        !cleanNumber.startsWith('016') &&
                        !cleanNumber.startsWith('017') &&
                        !cleanNumber.startsWith('018') &&
                        !cleanNumber.startsWith('019')) {
                      return '올바른 휴대폰 번호를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

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
                    labelText: 'E-mail',
                    prefixIcon: const Icon(Icons.email),
                    hintText: 'example@gmail.com',
                    errorStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.shade400,
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
                    suffixIcon:
                        _isEmailVerified
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                            : _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : TextButton(
                              onPressed:
                                  _isVerificationCodeSent && _countdown > 0
                                      ? null
                                      : _sendVerificationCode,
                              child: Text(
                                _isVerificationCodeSent && _countdown > 0
                                    ? '${(_countdown ~/ 60).toString().padLeft(2, '0')}:${(_countdown % 60).toString().padLeft(2, '0')}'
                                    : '인증',
                                style: TextStyle(
                                  color:
                                      _isVerificationCodeSent && _countdown > 0
                                          ? Colors.grey
                                          : Colors.blue,
                                ),
                              ),
                            ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요.';
                    }
                    // 이메일 형식 검증 (정규식 사용)
                    final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return '올바른 이메일 형식을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 인증 코드 입력 (인증 코드가 전송된 경우에만 표시)
                if (_isVerificationCodeSent)
                  Column(
                    children: [
                      TextFormField(
                        controller: _verificationCodeController,
                        focusNode: _verificationCodeFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          _passwordFocusNode.requestFocus();
                        },
                        decoration: InputDecoration(
                          labelText: '인증 코드',
                          prefixIcon: const Icon(Icons.security),
                          hintText: '6자리 숫자 입력',
                          errorStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blue.shade400,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_countdown > 0)
                                Text(
                                  '${(_countdown ~/ 60).toString().padLeft(2, '0')}:${(_countdown % 60).toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              _isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                    ),
                                  )
                                  : TextButton(
                                    onPressed:
                                        _countdown > 0
                                            ? null
                                            : _resendVerificationCode,
                                    child: Text(
                                      _countdown > 0 ? '재전송' : '재전송',
                                      style: TextStyle(
                                        color:
                                            _countdown > 0
                                                ? Colors.grey
                                                : Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              const SizedBox(width: 8),
                              _isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : IconButton(
                                    onPressed: _verifyCode,
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '인증 코드를 입력해주세요.';
                          }
                          if (value.length != 6) {
                            return '6자리 숫자를 입력해주세요.';
                          }
                          if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                            return '숫자만 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                // 비밀번호 입력
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    _confirmPasswordFocusNode.requestFocus();
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
                    hintText: '영문+숫자 포함 8자 이상',
                    errorStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.shade400,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요.';
                    }
                    if (value.length < 8) {
                      return '비밀번호는 8자 이상이어야 합니다.';
                    }
                    // 영문 포함 여부 확인
                    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                      return '영문을 포함해야 합니다.';
                    }
                    // 숫자 포함 여부 확인
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return '숫자를 포함해야 합니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 비밀번호 확인
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  obscureText: !_isConfirmPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    hintText: '비밀번호를 다시 입력해주세요',
                    errorStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.blue.shade400,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 다시 입력해주세요.';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // 회원가입 버튼
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    // 이메일 인증이 완료되었는지 확인
                    final isEmailVerified = _isEmailVerified;
                    final isVerificationCodeSent = _isVerificationCodeSent;
                    final isCountdownValid = _countdown > 0;

                    // 버튼 활성화 조건: 이메일 인증 완료 + 유효한 인증 코드 존재
                    final isButtonEnabled =
                        isEmailVerified &&
                        isVerificationCodeSent &&
                        isCountdownValid;

                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed:
                            (authProvider.isLoading || !isButtonEnabled)
                                ? null
                                : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isButtonEnabled ? Colors.blue : Colors.grey,
                        ),
                        child:
                            authProvider.isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  isButtonEnabled ? '회원가입' : '이메일 인증 필요',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
