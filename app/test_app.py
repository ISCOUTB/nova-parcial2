from app import app


def test_home():
    client = app.test_client()
    response = client.get("/")

    assert response.status_code == 200

    data = response.get_json()

    assert data["message"] == "Nova Taller 2 funcionando correctamente"
    assert "version" in data
    assert "environment" in data


def test_health():
    client = app.test_client()
    response = client.get("/health")

    assert response.status_code == 200

    data = response.get_json()

    assert data["status"] == "ok"
    assert "version" in data