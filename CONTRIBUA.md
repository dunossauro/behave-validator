# Objetivo do projeto

O objetivo desse projeto é montar uma extensão para o [Behave](https://github.com/behave/behave) capaz de validar dados genéricos em tabelas do Gherkin.

Essa biblioteca de validações é baseada em outras bibliotecas de validação, como o [WTForms](https://github.com/wtforms/wtforms) e o [Marshmallow](https://github.com/marshmallow-code/marshmallow).

Um exemplo:

```gherkin
Funcionalidade: Inserir usuários na API
  Cenário: Deve retornar usuário criado
    Quando o usuário for enviado para API:
      """
      {
        "nome": "Eduardo",
        "idade": 15,
        "sexo": "Masculino",
        "email": "eduardo@livedepython.org"
      }
      """
    Então a API deve responder
      | identificador | nome           | sexo      | email                    |
      | Number        | Text(length=7) | Masculino | eduardo@livedepython.org |
```

# Propósito da biblioteca

Existem diversos casos em testes onde não é possível ser totalmente determinístico. No exemplo acima não é possível determinar exatamente qual o valor do `identificador` do usuário. Mas é possível validar que o dado existe, já que uma das regras é que todo usuário tenha um identificador no banco de dados. Assim podemos saber que o tipo do valor do `indentificador` é `int`, ou de maneira mais genérica, `Number`, que pode ser considerado um tipo para qualquer valor numérico, como `int`, `float`, `complex`, ...


## Validadores

A idéia dos validadores é trabalhar com os possíves tipos de dados que podem ser encontrados em uma tabela e fazer a avaliação dos mesmos usando a biblioteca.


### Any

O tipo Any tem a função de checar somente se o valor existe, não se responsabilizando pela identificação do tipo ou mesmo pelo conteúdo. Isso ocorre em casos onde a tabela não consegue expor algum tipo de validação.

```Gherkin
Então a API deve retornar
 | mensagem | estado  |
 | Any      | Any     |
```


### Boolean

A idéia do tipo `Boolean` é fazer o esquema mais simples de validação, pois o boolean só tem dois estados.

```Gherkin
Então a API deve retornar
 | mensagem | estado  |
 | sucess   | Boolean |
```

Neste caso não será validada a resposta, mas somente se a API responder no formato correto.


### Number

Tipo genérico para qualquer forma numérica, pode-se pensar em [`numbers.Number`](https://docs.python.org/3.8/library/numbers.html#numbers.Number) (tipo genérico em Python). Com isso podemos usar todos os [métodos de comparação embutidos](https://docs.python.org/3.8/library/stdtypes.html#comparisons) no Python para fazer as validações. Algums exemplos:


| Método             |
| ------------------ |
| less_than     (<)  |
| less_equal    (<=) |
| greater_than  (>)  |
| greater_equal (>=) |
| not_equal     (!=) |

O que poderia resultar em validadores assim:
  - `Number`
    - valida somente se o valor é um número
 - `Number(less_than=7)`
   - valida o número se for menor do que 7
 - `Number(not_equal=10)`
   - valida o número se for diferente de 10

Obs: Nesse caso o método `equal (==)` não é aplicável, pois o número pode ser inserido literalmente na tabela.

### [Text](https://docs.python.org/3.8/library/stdtypes.html#text-sequence-type-str)

Além dos métodos de comparação, podem ser usados [métodos embutidos em iteráveis](https://docs.python.org/3.8/library/stdtypes.html#sequence-types-list-tuple-range) como:

| Método |
| ------ |
| len    |
| min    |
| max    |

Para que a API seja simplificada pode-se utilizar apenas combinações dos métodos:

| Método     | Validação       |
| ---------- | --------------- |
| length     | tamanho igual   |
| min_length | tamanho mínimo  |
| max_length | tamanho máximo  |


O que permite resultar em validadores como:

- `Text`
  - valida somente se o valor for uma string
- `Text(length=7)`
  - valida a string quando tiver o tamanho igual a 7
- `Text(min_length=7)`
  - valida a string quando tiver o tamanho mínimo de 7
- `Text(max_length=7)`
  - valida a string quando tiver o tamanho máximo de 7


A API de `Text` deve ser compatível com a definição de [typing.Text](https://docs.python.org/3.8/library/typing.html#typing.Text), onde é mantida a retrocompatibilidade com o tipo `unicode`.


### Date

...

### DateTime

...

## Posibilidade de extender

 ...


## API

Penso em levar a complexidade para validação de níveis para os steps

```Python
from behave import then
from behave_validator import validate_table

@then('a API deve responder')
def check_api_response(context):
  validate_table(context.table, data)
  ...
```

Onde a função `validate_table` se encarrega de fazer as validações. Para os tipos extendidos pelos usuários deve ser possível que esse decorador tenha mais uma camada de nível que possam ser passados para novas classes de validadores.

```Python
from behave import then
from behave_validator import validate_table, validator_regiter
from my_custon_validators import Person, Account

@then('a API deve responder')
@validator_regiter(Person, Account) # tenho dúdivas quanto a isso (talvez nos hooks, para usar em todo o projeto)
def check_api_response(context, validations):
  validate_table(context.table, data)
  ...
```


## Arquitetura

Podemos pensar em um modelo como o [ast.literal_eval](https://docs.python.org/3.8/library/ast.html#ast.literal_eval) presente na biblioteca padrão para fazer a avaliação das strings no código.


## Suporte a versões

O Behave atualmente [oferece suporte](https://github.com/behave/behave/blob/master/tox.ini) as versões do Python 3.2 em diante. Embora ofereça suporte ao Python 2, acredito que isso não deva estar no roadmap.

## Integração contínua

Penso em usar o tox para trabalhar com versões do Python no mesmo test runner.

## Testes


## Padronização de código

Pretendo seguir a risca a PEP-8 e a PEP-257. Todo o código deve ser formatado com [Black](https://github.com/python/black). Sempre quando houver dúvidas sobre identação, opte por [Vertical Hanging Indent](https://github.com/timothycrosley/isort).
