import os
from io import BytesIO

from PIL import Image
from django.contrib.auth.base_user import AbstractBaseUser, BaseUserManager
from django.contrib.auth.models import User
from django.contrib.auth.validators import UnicodeUsernameValidator
from django.core.files import File
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.utils.translation import gettext_lazy as _
from rest_framework.authtoken.models import Token

from Auth.validators import validate_age, validate_not_null_string, validate_gender
from BackEnd import settings
from BackEnd.settings import MEDIA_ROOT

class Role:
    ADMIN = "ADM"
    MODERATOR = "MOD"
    MEMBER = "MEM"
    ROLE_CHOICES = (
        (ADMIN, "Admin"),
        (MODERATOR, "Modérateur"),
        (MEMBER, "Membre")
    )

class Nationality:
    FRENCH = "FRE"
    JAPANESE = "JAP"
    NATIONALITY_CHOICES = (
        (FRENCH, "Français"),
        (JAPANESE, "Japonais"),
    )

def get_avatar_path(instance, filename):
    if Account.object.count() == 0:
        return "defaultAvatar.png"

    try:
        path = os.path.join(MEDIA_ROOT, 'Avatar', str(instance.id))
        for i in os.listdir(path):
            if os.path.isfile(os.path.join(path, i)) and 'Avatar' in i:
                os.remove(os.path.join(path, i))
    except FileNotFoundError:
        pass


    if instance.id is None:
        return os.path.join('Avatar', str(Account.object.last().id + 1), ("Avatar" + os.path.splitext(filename)[1]))
    return os.path.join('Avatar', str(instance.id), ("Avatar" + os.path.splitext(filename)[1]))

def compress(image):
    im = Image.open(image)
    if im.mode in ("RGBA", "P"):
        im = im.convert("RGB")
    im_io = BytesIO()
    im.save(im_io, 'JPEG', quality=25)
    new_image = File(im_io, name=image.name)
    return new_image


class MyAccountManager(BaseUserManager):
    def create_user(self, username, email, password=None):
        if not email:
            raise ValueError(_('User must have an email address'))
        if not username:
            raise ValueError(_('User must have a username'))

        user = self.model(email=self.normalize_email(email), username=username)

        user.set_password(password)
        user.save_avatar(using=self.db)
        return user

    def create_superuser(self, username, email, password):
        user = self.create_user(username, email, password)
        user.is_admin = True
        user.is_staff = True
        user.is_superuser = True
        user.save_avatar(using=self.db)
        return user


class Account(AbstractBaseUser):
    username = models.CharField(_('username'), max_length=30, unique=True,
                                help_text=_('Required. 30 characters or fewer. Letters, digits and @/./+/-/_ only.'),
                                validators=[UnicodeUsernameValidator()],
                                error_messages={'unique': _("A user with that username already exists.")}, )
    email = models.EmailField(verbose_name='email', max_length=60, unique=True)
    avatar = models.ImageField(upload_to=get_avatar_path, default="defaultAvatar.png")

    first_name = models.CharField(validators=[validate_not_null_string], max_length=50)
    last_name = models.CharField(validators=[validate_not_null_string], max_length=50)
    age = models.PositiveIntegerField(validators=[MinValueValidator(14)])
    city = models.CharField(validators=[validate_not_null_string], max_length=25)
    country = models.CharField(validators=[validate_not_null_string], max_length=25)
    gender = models.PositiveIntegerField(validators=[MinValueValidator(0), MaxValueValidator(2)])

    role = models.CharField(max_length=3, choices=Role.ROLE_CHOICES, default=Role.MEMBER)
    nationality = models.CharField(max_length=3, choices=Nationality.NATIONALITY_CHOICES)

    show_first_name = models.BooleanField(default=False)
    show_last_name = models.BooleanField(default=False)
    show_age = models.BooleanField(default=True)
    show_city = models.BooleanField(default=True)
    show_country = models.BooleanField(default=True)
    show_gender = models.BooleanField(default=True)

    date_joined = models.DateTimeField(verbose_name='date joined', auto_now_add=True)
    last_login = models.DateTimeField(verbose_name='last login', auto_now=True)

    is_admin = models.BooleanField(default=False, blank=True)
    is_active = models.BooleanField(default=True, blank=True)
    is_staff = models.BooleanField(default=False, blank=True)
    is_superuser = models.BooleanField(default=False, blank=True)

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']

    object = MyAccountManager()

    def __str__(self):
        return self.username

    def has_perm(self, perm, obj=None):
        return self.is_admin

    def has_module_perms(self, app_label):
        return True

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)

    def save_avatar(self, *args, **kwargs):
        new_image = compress(self.avatar)
        self.avatar = new_image
        self.save(*args, **kwargs)

    def change_role(self, roleAlias):
        for role in Role.ROLE_CHOICES:
            if role[0] == roleAlias:
                self.role = role[0]
                self.save()
                return

    def change_nationality(self, nationalityAlias):
        for nationality in Nationality.NATIONALITY_CHOICES:
            if nationality[0] == nationalityAlias:
                self.nationality = nationality[0]
                self.save()
                return

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)