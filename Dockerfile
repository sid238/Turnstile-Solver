FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    HOME=/home/user \
    PLAYWRIGHT_BROWSERS_PATH=/home/user/.cache/ms-playwright \
    PATH="/home/user/.local/bin:$PATH"

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales tzdata ca-certificates \
    python3 python3-pip python3-dev \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libdrm2 libxkbcommon0 \
    libxcomposite1 libxdamage1 libxfixes3 \
    libxrandr2 libgbm1 libasound2 \
    libpangocairo-1.0-0 libpango-1.0-0 \
    libxss1 fonts-liberation fonts-noto-color-emoji \
    curl wget git \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# HF Spaces requirement
RUN useradd -m -u 1000 user
USER user

WORKDIR /home/user/app

# Copy project
COPY --chown=user:user . .

# Install python dependencies
RUN pip3 install --no-cache-dir --user -r requirements.txt

# Install browsers (Patchright + Playwright fallback)
RUN python3 -m patchright install chromium --with-deps \
    || python3 -m playwright install chromium

EXPOSE 7860

CMD ["python3", "main.py", "--host", "0.0.0.0", "--port", "7860"]
