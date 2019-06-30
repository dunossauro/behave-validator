# Objetivo do projeto

O objetivo desse projeto é montar uma extensão para o [Behave](https://github.com/behave/behave) capaz de validar dados gernéricos em tabelas do Gherkin.

Essa biblioteca de validações é baseada em outra bibliotecas de validação, como o [WTForms](https://github.com/wtforms/wtforms) e o [Marshmallow](https://github.com/marshmallow-code/marshmallow)

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

Existem diversos casos em testes onde não é possível ser totalmente deterministico. No exemplo passado não é possível determinar exatamente qual o valor do `identificador` do usuário. Mas é possível validar que o dado existe, dado que uma das regras é que todo usuário tenha um identificador no banco de dados. Então dessa maneira sabemos que o tipo do valor do `indentificador` é `int` ou de maneira mais genérica `Number`, que pode ser consideirado um tipo genérico para qualquer tipo de valor numérico. Como `int`, `float`, `complex` ...


## Validadores

A ideia dos validadores é trabalhar com os possíves tipos de dados que poderiam ser encontrados em uma tabela e fazer a avaliação dos mesmos usando a biblioteca.


### Any

O tipo Any tem a função de checar somente se o valor existe, não se responsabilizando pelo tipo ou mesmo pelo conteúdo. Pois em casos onde a tabela não conseguiria expor algum tipo de validação.

```Gherkin
Então a API deve retornar
 | mensagem | estado  |
 | Any      | Any     |
```


### Bollean

A ideia do tipo `Boolean` é fazer o tipo mais simples de validação, pois o boolean só tem dois estados

```Gherkin
Então a API deve retornar
 | mensagem | estado  |
 | sucess   | Bollean |
```

No caso onde não será validada a resposta. Mas somente se a API está respondendo no formato correto


### Number

Tipo genérico para qualquer tipo de numero, pode-se pensar em [`numbers.Number`](https://docs.python.org/3.8/library/numbers.html#numbers.Number) (tipo genérico em python). Com isso podemos usar todos os [métodos de comparação embutidos](https://docs.python.org/3.8/library/stdtypes.html#comparisons) no Python para fazer as validações. Algums exemplos:


| Método             |
| ------------------ |
| less_then     (<)  |
| less_equal    (<=) |
| greater_than  (>)  |
| greater_equal (>=) |
| not_equal     (!=) |

O que poderia resultar em validadores assim:
  - `Number`
    - valida somente se o valor é um número
 - `Number(less_then=7)`
   - onde o número deveria ser menor do que 7
 - `Number(not_equal=10)`
   - Onde o número não pode ser 10

obs: acredito que nesse caso o método equal (==) não é aplicável, pois o numero poderia ser inserido literal na tabela.

### [Text](https://docs.python.org/3.8/library/stdtypes.html#text-sequence-type-str)

Além dos métodos de comparação poderiam ser usados [métodos embutidos em iteráveis](https://docs.python.org/3.8/library/stdtypes.html#sequence-types-list-tuple-range) como:

| Método |
| ------ |
| len    |
| min    |
| max    |

Porém acredito que para que a API sejá simplficada podemos usar somente combinações dos métodos

| Método     | Validação       |
| ---------- | --------------- |
| length     | tamanho igual   |
| min_length | tamanho mínimo  |
| max_length | tamanho máximo  |


O que poderia resultar em validadores assim:
- `Text`
  - valida somente se o valor é uma string
- `Text(length=7)`
  - onde a string deveria ter o tamanho igual a 7
- `Text(min_length=7)`
  - onde a string deveria ter o tamanho mínimo de 7
- `Text(max_length=7)`
  - onde a string deveria ter o tamanho máximo de 7


Acredito que a API de Text deve ser compatível com a definição de [typing.Text](https://docs.python.org/3.8/library/typing.html#typing.Text) onde é mantida a retrocampatibilidade com o tipo `unicode`


### Date

...

### DateTime

...

## Posibilidade de extender

 ...


## API

Penso em levar a complexidade para validação a nível para os steps

```Python
from behave import then
from behave_validator import validate_table

@then('a API deve responder')
def check_api_response(context):
  validate_table(context.table, data)
  ...
```

Onde a função `validate_table` se encarrege de fazer as validações. Para os tipos extendidos pelos usuários deve ser possível que esse decoradore tenha mais uma camada a nível que possam ser passados novas classes de validadores.

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
...

## Suporte a versões

O behave atualmente [oferece suporte](https://github.com/behave/behave/blob/master/tox.ini) as verões maiores do python 3.2, ebora ofereça suporte ao python 2, acredito que isso não deva estar no roadmap

## Integração contínua

Penso em usar o tox para trabalhar com versões do python no mesmo test runner

## Testes


## padronização de código

Pretendo seguir a risca a PEP-8 e a PEP-257, todo o código deve ser formatado com [Black](https://github.com/python/black). Sempre onde houver dúvidas sobre identação, opte sempre por [Vertical Hanging Indent](https://github.com/timothycrosley/isort)
