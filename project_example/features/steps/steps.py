from behave import when, then


@when('o usuário for enviado para API')
def insert_user(context):
    ...


@then('a API deve responder')
def check_api_response(context):
    context.table
