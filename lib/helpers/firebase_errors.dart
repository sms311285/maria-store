// Erros de autenticação do Firebase
String getErrorString(String code) {
  switch (code) {
    case 'invalid-email':
      return 'Seu e-mail é inválido.';
    case 'wrong-password':
      return 'Sua senha está incorreta.';
    case 'user-not-found':
      return 'Não há usuário com este e-mail.';
    case 'invalid-credential':
      return 'Suas credenciais são inválidas.';
    case 'user-disabled':
      return 'Este usuário foi desabilitado.';
    case 'too-many-requests':
      return 'Muitas solicitações. Tente novamente mais tarde.';
    case 'operation-not-allowed':
      return 'Operação não permitida.';
    default:
      return 'Um erro indefinido ocorreu.';
  }
}
