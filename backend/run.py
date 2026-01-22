import uvicorn
from app.seed import seed

if __name__ == "__main__":
    seed()
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
