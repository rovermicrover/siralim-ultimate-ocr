FROM ruby:3.1.2

# TESSERACT
ARG TESSERACT_VERSION="5.2.0"
ARG TESSERACT_URL="https://api.github.com/repos/tesseract-ocr/tesseract/tarball/$TESSERACT_VERSION"

# install basic tools
RUN apt-get update && apt-get install --no-install-recommends --yes \
    apt-transport-https \
    asciidoc \
    automake \
    bash \
    ca-certificates \
    curl \
    docbook-xsl \
    g++ \
    git \
    libleptonica-dev \
    libtool \
    libicu-dev \
    libpango1.0-dev \
    libcairo2-dev \
    make \
    pkg-config \
    wget \
    xsltproc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN wget -qO tesseract.tar.gz $TESSERACT_URL && \
    tar -xzf tesseract.tar.gz && \
    rm tesseract.tar.gz && \
    mv tesseract-* tesseract

WORKDIR /src/tesseract

RUN ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    ldconfig

WORKDIR /usr/local/share/tessdata/
RUN wget -qO eng.traineddata https://github.com/tesseract-ocr/tessdata_best/blob/main/eng.traineddata?raw=true

WORKDIR /code/

RUN apt-get update

RUN apt-get install -y \
  imagemagick \
  && rm -rf /var/lib/apt/lists/*

RUN gem install bundler

COPY ./Gemfile ./Gemfile

RUN bundle install

COPY ./ ./

CMD ["ruby", "main.rb"]