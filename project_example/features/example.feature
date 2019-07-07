# language:pt

Funcionalidade: Inserir usuários na API
  Cenário: Deve retornar usuário criado
    Quando o usuário for enviado para API
      """
      {
        "nome": "Eduardo",
        "idade": 15,
        "sexo": "Masculino",
        "email": "eduardo@livedepython.org"
      }
      """
    Então a API deve responder
      | identificador* | idade  | nome           | sexo      | email                    |
      | Any            | Number | Text(length=7) | Masculino | eduardo@livedepython.org |
