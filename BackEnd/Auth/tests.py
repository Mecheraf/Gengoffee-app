from django.test import SimpleTestCase
from django.urls import reverse, resolve
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from Auth.views import api_user_info_view, api_register_user_view, api_login_user_view, api_logout_user_view, \
    api_user_update_view


class UrlsTestCase(SimpleTestCase):
    def test_GetAccount_url_is_resolved(self):
        url = reverse('GetAccount')
        self.assertEquals(resolve(url).func, api_user_info_view)

    def test_Register_url_is_resolved(self):
        url = reverse('Register')
        self.assertEquals(resolve(url).func, api_register_user_view)

    def test_Login_url_is_resolved(self):
        url = reverse('Login')
        self.assertEquals(resolve(url).func, api_login_user_view)

    def test_Logout_url_is_resolved(self):
        url = reverse('Logout')
        self.assertEquals(resolve(url).func, api_logout_user_view)

    def test_UpdateAccount_url_is_resolved(self):
        url = reverse('UpdateAccount')
        self.assertEquals(resolve(url).func, api_user_update_view)


class AccountTestCase(APITestCase):
    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self.good_users_data = [
            {
                "username": "Julo",
                "email": "azeaujulien@gmail.com",
                "first_name": "Julien",
                "last_name": "Azeau",
                "age": 19,
                "country": "France",
                "city": "Limeil-Brévannes",
                "gender": 0,
                "password": "Password1234!",
                "password2": "Password1234!",
                "token": '',
            },
            {
                "username": "ヤテ",
                "email": "takeshiyamamoto@gmail.com",
                "first_name": "武",
                "last_name": "山本",
                "age": 18,
                "country": "日本",
                "city": "並盛",
                "gender": 0,
                "password": "Password1234!",
                "password2": "Password1234!",
                "token": '',
            }
        ]

        self.good_users_modified_data = [
            {
                "username": "Julo2",
                "email": "azeaujulien2@gmail.com",
                "first_name": "Julien2",
                "last_name": "Azeau2",
                "age": 19,
                "country": "France2",
                "city": "Limeil-Brévannes2",
                "gender": 0,
            },
            {
                "username": "ヤテ2",
                "email": "takeshiyamamoto2@gmail.com",
                "first_name": "武2",
                "last_name": "山本2",
                "age": 18,
                "country": "日本2",
                "city": "並盛2",
                "gender": 0,
            }
        ]

        self.user_under_aged = {
            "username": "Julo",
            "email": "azeaujulien@gmail.com",
            "first_name": "Julien",
            "last_name": "Azeau",
            "age": 5,
            "country": "France",
            "city": "Limeil-Brévannes",
            "gender": 0,
            "password": "Password1234!",
            "password2": "Password1234!",
        }

        self.user_with_not_good_gender = {
            "username": "Julo",
            "email": "azeaujulien@gmail.com",
            "first_name": "Julien",
            "last_name": "Azeau",
            "age": 18,
            "country": "France",
            "city": "Limeil-Brévannes",
            "gender": 5,
            "password": "Password1234!",
            "password2": "Password1234!",
        }

        self.user_with_empty_fields = {
            "username": "Julie",
            "email": "azeaujuli@gmail.com",
            "first_name": "",
            "last_name": "",
            "age": 18,
            "country": "",
            "city": "",
            "gender": 1,
            "password": "Password1234!",
            "password2": "Password1234!",
        }

    def test_user_cannot_register_with_no_data(self):
        response = self.client.post(reverse('Register'))
        self.assertEqual(response.status_code, 400)

    def test_user_cannot_register_with_wrong_data(self):
        under_aged_response = self.client.post(reverse('Register'), self.user_under_aged, format="json")
        self.assertEqual(under_aged_response.status_code, 400)

        not_good_gender_response = self.client.post(reverse('Register'), self.user_with_not_good_gender, format="json")
        self.assertEqual(not_good_gender_response.status_code, 400)

        empty_fields_response = self.client.post(reverse('Register'), self.user_with_empty_fields, format="json")
        self.assertEqual(empty_fields_response.status_code, 400)

    def test_user_can_register_and_login_and_get_and_update_and_logout(self):
        self.user_can_register()
        self.user_can_login()
        self.can_get_user()
        self.user_can_update()
        self.user_can_logout()

    def user_can_register(self):
        i = 0
        for user in self.good_users_data:
            user_response = self.client.post(reverse('Register'), user, format="json")
            self.assertEqual(user_response.status_code, 201)
            self.verify_user(i, user_response.data)
            self.assertNotEqual(user_response.data['token'], '')
            user['token'] = user_response.data['token']
            i += 1

    def test_user_cannot_login_with_no_data(self):
        response = self.client.post(reverse('Register'))
        self.assertEqual(response.status_code, 400)

    def user_can_login(self):
        i = 0
        for user in self.good_users_data:
            login_data = {
                'username': user['username'],
                'password': user['password'],
            }
            user_response = self.client.post(reverse('Login'), login_data, format="json")
            self.assertEqual(user_response.status_code, 200)
            self.assertEqual(user['token'], user_response.data['token'])
            self.verify_user_hide(i, user_response.data['user'])
            i += 1

    def verify_user(self, userId, data):
        user = self.good_users_data[userId]
        self.assertEqual(user["username"], data["username"])
        self.assertEqual(user["email"], data["email"])
        self.assertEqual(user["first_name"], data["first_name"])
        self.assertEqual(user["last_name"], data["last_name"])
        self.assertEqual(user["age"], data["age"])
        self.assertEqual(user["country"], data["country"])
        self.assertEqual(user["city"], data["city"])
        self.assertEqual(user["gender"], data["gender"])

    def verify_modified_user(self, userId, data):
        user = self.good_users_modified_data[userId]
        self.assertEqual(user["username"], data["username"])
        self.assertEqual(user["email"], data["email"])
        self.assertEqual(user["first_name"], data["first_name"]['value'])
        self.assertEqual(user["last_name"], data["last_name"]['value'])
        self.assertEqual(user["age"], data["age"]['value'])
        self.assertEqual(user["country"], data["country"]['value'])
        self.assertEqual(user["city"], data["city"]['value'])
        self.assertEqual(user["gender"], data["gender"]['value'])

    def verify_user_hide(self, userId, data):
        user = self.good_users_data[userId]
        self.assertEqual(user["username"], data["username"])
        self.assertEqual(user["email"], data["email"])
        self.assertEqual(user["first_name"], data["first_name"]['value'])
        self.assertEqual(user["last_name"], data["last_name"]['value'])
        self.assertEqual(user["age"], data["age"]['value'])
        self.assertEqual(user["country"], data["country"]['value'])
        self.assertEqual(user["city"], data["city"]['value'])
        self.assertEqual(user["gender"], data["gender"]['value'])

    def can_get_user(self):
        i = 0
        for user in self.good_users_data:
            if user['token'] == '':
                continue

            self.client.credentials(HTTP_AUTHORIZATION='Token ' + user['token'])
            user_response = self.client.get(reverse('GetAccount'), format="json")
            self.assertEqual(user_response.status_code, 200)
            self.verify_user_hide(i, user_response.data)
            i += 1

    def can_get_modified_user(self, userId):
        user = self.good_users_data[userId]
        if user['token'] == '':
            return

        self.client.credentials(HTTP_AUTHORIZATION='Token ' + user['token'])
        user_response = self.client.get(reverse('GetAccount'), format="json")
        self.assertEqual(user_response.status_code, 200)
        self.verify_modified_user(userId, user_response.data)

    def user_can_update(self):
        i = 0
        for user in self.good_users_data:
            if user['token'] == '':
                continue

            modify_user = self.good_users_modified_data[i]
            self.client.credentials(HTTP_AUTHORIZATION='Token ' + user['token'])
            user_response = self.client.put(reverse('UpdateAccount'), modify_user, format="json")
            self.assertEqual(user_response.status_code, 200)
            self.can_get_modified_user(i)
            i += 1

    def user_can_logout(self):
        i = 0
        for user in self.good_users_data:
            if user['token'] == '':
                continue

            self.client.credentials(HTTP_AUTHORIZATION='Token ' + user['token'])
            logout_response = self.client.get(reverse('Logout'), format="json")
            self.assertEqual(logout_response.status_code, 200)
            token = Token.objects.filter(key=user['token'])
            self.assertEqual(len(token), 0)

            i += 1
