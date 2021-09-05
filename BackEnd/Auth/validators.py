from django.core.exceptions import ValidationError


def validate_age(value):
    if value < 13:
        raise ValidationError(
            'Age must be greater than 13',
            params={'value': value},
        )

def validate_gender(value):
    if value < 0 or value > 2:
        raise ValidationError(
            'Gender must be between 0 and 3',
            params={'value': value},
        )

def validate_not_null_string(value):
    if not value:
        raise ValidationError(
            'String cannot be null or empty',
            params={'value': value},
        )