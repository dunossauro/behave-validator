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
      | identificador* | idade  | nome           | sexo      | email                    |
      | Any            | Number | Text(length=7) | Masculino | eduardo@livedepython.org |
```

> `identificador` pode ser consideirada a referência do objeto no banco de dados


# Propósito da biblioteca

Existem diversos casos em testes onde não é possível ser totalmente deterministico. No exemplo passado não é possível determinar exatamente qual o valor do `identificador` do usuário no banco de dados, usado no exemplo acima. Mas é possível validar que o dado existe, visto que uma das regras é que todo objeto tenha um identificador no banco de dados. Então dessa maneira sabemos que o tipo do valor do `indentificador` é `int`, imaginando um banco de dados relacional, ou de maneira mais geral, `Number`, que pode ser consideirado um tipo genérico para qualquer tipo de valor numérico, como `int`, `float` e `complex`. Em outros casos pode ser que o banco usado seja o [mongodb](https://www.mongodb.com/) onde o tipo do identificador é um [`ObjectId`](https://docs.mongodb.com/manual/reference/method/ObjectId/). Nesse caso fica praticamente inviável validar o tipo. Pois o valor é dado partindo de um hash em hexadecimal. Podemos usar `Any`, pra validar somente que o valor existe na resposta da API, por exemplo.
Os estilos de uso da biblioteca tendem a ser ilimitados em relação a bibliotecas externas utilizadas. Ou seja, será uma lib de validação genérica.


## Validadores

A idéia dos validadores é trabalhar com os possíves tipos de dados que podem ser encontrados em uma tabela e fazer a avaliação dos mesmos usando a biblioteca.


### Validadores estáticos

Tipos de validadores onde somente o tipo deve ser suficiente para o match ocorrer. Ou seja, não há parâmetros para esse validadores. `Any` por exemplo, só deve checar se o valor recebido existe, indepente do seu tipo. Já o validador `Boolean` deve checar se o tipo recebido corresponde ao range de valores `True` ou `False`.


#### Any

O tipo `Any` tem a função de checar somente se o valor existe, não se responsabilizando pela identificação do tipo ou mesmo pelo conteúdo. Isso ocorre em casos onde a tabela não consegue expor algum tipo de validação.

```Gherkin
Então a API deve retornar
 | mensagem | estado  |
 | Any      | Any     |
```


#### Boolean

A idéia do tipo `Boolean` é fazer o esquema mais simples de validação, pois o boleano só tem dois estados.

```Gherkin
Então a API deve retornar
 | mensagem | estado  |
 | sucess   | Boolean |
```

No caso acima não será validada a resposta. Mas somente se a API está respondendo no formato correto, `True` ou `False`.


### Validadores dinâmicos

Validadores dinâmicos devem extender funcionalidades de validadores estáticos. Pois além de fazer a validação do tipo, podem fazer outras validações. Como exemplo vamos usar o validator `Text`. Ele pode ser usado em sua forma mais simples, estática. `Text`, onde o valor passado ao validador será somente comparado a nível de tipagem. Ou seja, se é uma string. Porém, também é possível usar a forma dinâmica. `Text(max_length=10)`. Nesse caso a validação do tipo vai ocorrer, porém também será checado se o tamanho máximo da string é de 10 caracteres.


#### Number

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


#### [Text](https://docs.python.org/3.8/library/stdtypes.html#text-sequence-type-str)

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


#### Date

...


#### DateTime

...


## Posibilidade de extender novos validadores

...


## API

Penso em levar a complexidade para validação de níveis para os steps.

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

A implementação pode ser pensanda em 3 atores principais.

`Dispatcher`, `Validator`, `Register`

...


### validate_table

> TODO: pensar em um nome melhor pra essa função # validate_rows ?

Função responsável por fazer o filtro por rows da tabela e separar os valores em três camadas.

- `string_matches`: Valores para quais os validators da biblioteca não foram definidos
- `static_matches`: Valores definidos com validators estáticos
- `dynamic_matches`: Valores onde validadores dinâmicos foram definidos

Por exemplo, a função deve evocar a camada do `Dispatcher` para que ele diga se é um validador e qual o seu tipo.

```Python
def validate_table(context.table, sequence_data):
    ...
```
...


### Dispatcher
Podemos pensar em um modelo como o [ast.literal_eval](https://docs.python.org/3.8/library/ast.html#ast.literal_eval) presente na biblioteca padrão para fazer a avaliação das strings no código.

Exemplos:

Quando o valor recebido não for um validador registrado, a mesma string que foi recebida deve ser retornada

```Python
>>> validator_eval('7')
'7'
```

Os tipos estáticos de validadores, como `Any`, `Boolean`

```Python
>>> validator_eval('StaticValidatorClass')
ValidatorClass
```

```Python
>>> validator_eval('DynamicValidatorClass(validation_a=7, validation_B=14)')
DynamicValidatorClass, validators
```

> onde `validators` será um dicionário para as chamadas dos invocáveis correspondentes

Com isso podemos montar um esquema de dispatchers. Onde o ...


### Validator

Onde o tipo `Validator` deverá implementar 3 métodos

- `validate_error`: Retorna o erro de determinado validador
- `validate_type`: Efetua a validação do tipo
- `__call__`: Executa a chamada de `validate_type` e retorna seu erro, ou sucesso

```Python
from abc import abstractmethod, ABCMeta


class MetaStaticValidator(abc=ABCMeta):
    """
    >>> msv = MetaStaticValidator()

    >>> msv.validate_type('string bolada')
    # MetaStaticValidatorException: 1 is not Text

    >>> msv.validate_type(False)
    True, False

    >>> msv(True)
    True
    """
    @abstractmethod
    def __init__(self):
        ...

    @abstractmethod
    def validate_error(self, **kwargs):
        """Retorna um erro customizado para o validator."""
        ...

    @abstractmethod
    def validate_type(self):
      """Efetua a validação do tipo."""
      ...

    @abstractmethod
    def __call__(self):
      """Executa a chamada de `validate_type` e retorna seu erro, ou sucesso."""
      ...
```

### DynamicValidator

Os validadores dinâmicos devem herdar dos validadores estáticos, como já foi dito, todo validador dinâmico também deve ser passível de uso em sua forma estática.

Para que seja possível fazer as validações dinâmicas, os `DynamicValidator`s devem implementar também um método próprio

- `validate_fields`: Método que aplica todas as validações além da tipagem.


```Python
from abc import abstractmethod
from _validators_abc import MetaStaticValidator

class MetaDynamicValidator(abc=Meta, MetaStaticValidator):
    """
    >>> mdv = MetaDynamicValidator()
    >>> mdv('value', validator_1='a', validator_2='b')
    # MetaDynamicValidatorException: 'value' fails in 'validator_1'
    """
    @abstractmethod
    def validate_fields(self, **validators):
        """Método que aplica todas as validações além da tipagem."""
        ...

```

### Register

...


### Exceptions

A excessão base deve ser herdada de [BaseException](https://docs.python.org/3.7/library/exceptions.html#BaseException) e partindo dela devem ser criadas as novas classes

```Python
class BaseValidatorException(BaseException):
    ...
```

Onde poderá ser utilizada com uma boa formatação para que seja possível ver o erro.

```Python
>>> val = 1
>>> raise BaseValidatorException(f'{val} is not Text')
# BaseValidatorException: 1 is not Text
```


## Suporte a versões

O Behave atualmente [oferece suporte](https://github.com/behave/behave/blob/master/tox.ini) as versões do Python 3.2 em diante. Embora ofereça suporte ao Python 2, acredito que isso não deva estar no roadmap.


## Integração contínua

Penso em usar o tox para trabalhar com versões do Python no mesmo test runner. Porém, acredito que a escolha da ferramenta de CI, possa ser decidida pelo time.

Alternativas:

- [travis-ci](https://travis-ci.org/)
- [circle-ci](https://circleci.com/)
- [gitlab-ci](https://about.gitlab.com/product/continuous-integration/)


## Testes

...


## Padronização de código

Pretendo seguir a risca a [PEP-8](https://www.python.org/dev/peps/pep-0008/) e a [PEP-257](https://www.python.org/dev/peps/pep-0257/). Todo o código deve ser formatado com [Black](https://github.com/python/black). Sempre quando houver dúvidas sobre identação, opte por [Vertical Hanging Indent](https://github.com/timothycrosley/isort).
