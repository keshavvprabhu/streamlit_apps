import pytest
from utils.modules import PaymentParty

class TestPaymentParty:
    def setup_method(self):
        self.payment_party = PaymentParty(locale='en_US')

    def test_get_name(self):
        name = self.payment_party.get_name()
        assert isinstance(name, str)
        assert len(name) > 0
        assert name is not None

    def test_get_uetr_id(self):
        uetr_id = self.payment_party.get_uetr_id()
        assert isinstance(uetr_id, str)
        assert len(uetr_id) == 36  # UUID length
        assert

    def test_get_state_or_province(self):
        state = self.payment_party.get_state_or_province()
        assert isinstance(state, str)
        assert len(state) > 0
        assert state is not None

    def test_get_country(self):
        country = self.payment_party.get_country()
        assert isinstance(country, str)
        assert len(country) > 0
        assert country is not None


if __name__ == "__main__":
    pass