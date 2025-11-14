# Base com Java 17 (Temurin)
FROM eclipse-temurin:17-jdk

# Instala Python 3, pip e curl
RUN apt-get update && \
    apt-get install -y python3 python3-venv python3-pip curl && \
    rm -rf /var/lib/apt/lists/*

# Define diretório de trabalho
WORKDIR /app

# Variáveis de ambiente Java
ENV JAVA_HOME=/usr/lib/jvm/java-17-temurin
ENV PATH="$JAVA_HOME/bin:$PATH"

# Instala Spark
ENV SPARK_VERSION=3.5.1
ENV HADOOP_VERSION=3

RUN curl -L -o spark.tgz \
    https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xzf spark.tgz -C /opt && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /opt/spark && \
    rm spark.tgz

ENV SPARK_HOME=/opt/spark
ENV PATH="$SPARK_HOME/bin:$PATH"
ENV PYSPARK_PYTHON=python3

# Cria e ativa virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Atualiza pip e instala dependências dentro do venv
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install jupyterlab

# Copia o restante do código
COPY . .

# Expõe porta do Jupyter
EXPOSE 8888

# Comando padrão
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]