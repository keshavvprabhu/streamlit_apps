import json
import os
from loguru import logger
from faker import Faker


class PaymentParty:
    def __init__(self, locale="en_US"):
        self.faker = Faker(locale)
        self.locale = locale

    def get_name(self):
        return self.faker.name()

    def get_uetr_id(self):
        return self.faker.uuid4()

    def get_state_or_province(self):
        return self.faker.state()

    def get_country(self):
        return self.faker.country()


if __name__ == "__main__":
    pass
