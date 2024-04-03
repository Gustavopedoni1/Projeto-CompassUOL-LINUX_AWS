
# Projeto-CompassUOL-LINUX_AWS

# *Requisitos no linux:*

Entrando em modo root:
```
sudo su
```

Atualizando os pacotes do sistema:
```
yum update
```


 •	*Configurar o NFS ;*

 - Instalando o pacote efs no linux através do comando :
```
amazon-efs-utils
```

•	*Criar um diretório dentro do filesystem do NFS com seu nome;*

- Criando diretório local que servirá como ponto de montagem e também o diretório dentro do filesystem do NFS com seu nome
  
```
/mnt/nfs/gustavo
```

- Montando o Efs ao Linux/servidor. Para isto, é preciso utilizar o comando que deve ser copiado da console aws>>EFS>>atach(anexar), exemplo de comando  ``` sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-079d051a3841fbcc8.efs.us-east-1.amazonaws.com:/ /mnt/nfs```, lembrando que cada um terá o seu próprio DNS, e caminho local, que aqui foi nomeado como /mnt/nfs;
             
                                                               
- Verificar se o EFS esta funcionando através do comando :
  ``` df -h ```
  
![df -h para ver se o efs esta rodando ok](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/2c8e8ad9-6b26-48a6-8673-fa424f33d374)




Para evitarmos que o EFS pare após o a instância/servidor ser reiniciado devemos fazer uma alteração no arquivo fstab que esta dentro do diretório ```/etc```.



![fstab](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/fe6c3cd8-741f-4fb2-92e9-6276091d94bd)




Com o comando ``` nano /etc/fstab ```,  abriremos o aquivo:


![FSTAB ORIGINAL](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/0cc70358-1e73-4811-8aa1-992fefc06e80)

Devemos acresentar mais uma linha de comando com a seguinte sintaxe ``` DNS:/ /mnt/nfs nfs4 defaults  0 0 ```, não esqueça de subistituir o DNS pelo dns do seu EFS que você encontrará na console aws. Veja um exemplo do arquivo já editado:


![fstab (2)](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/a3d0d41d-aeaf-43cf-b199-a18fda5e9f05)


 
 •	*Subir um apache no servidor - o apache deve estar online e rodando;*

- Instalando o Apache com o comando ``` yum install httpd -y ``` 
 
- Iniciando o Apache no sistema com o comando ``` service httpd start ```
 
- conferindo se o apache esta rodando com o comando ``` service httpd status ``` que devera mostrar a seguinte mensagem :

![status do apache rodando](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/00e5c20e-a850-4a72-834a-29a27278da3d)



O Apache já vem com uma página inicial padrão que pode ser acessada através da digitação do IP público da instância na barra de endereço de um navegador. 

![APACHE](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/3ad2855c-4932-4074-a4a5-a70e989e486d)

Porém é possível editar essa página HTML para que exiba o que você quiser. Para isto ser feito devemos navergar até o diretório html ```  cd /var/www/html ``` estando no diretório, se fizermos uma listagem dos arquivos ( ``` ls ``` ) veremos o arquivo index.html : 

![image](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/7f3bb088-8f90-40f6-bee8-6e359c1eedd6)

Usando o comando ``` nano index.html ``` abriremos para edição. O arquivo HTML que você digitar nesse documento é o que será mostrado na página acessada pelo IP público. Veja a seguir um exemplo de documento HTML para o serviço:

![Index htmleditado](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/b16b00b5-9116-482c-86d7-1f5fe08e5505)

Podemos também abri a edição do arquivo index.html de forma mais direta, com o seguinte comando ``` nano /var/www/html/index.html```

O resultado do script apresentado foi : 

![apache ok](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/13c8230b-86c3-4e79-86d6-8871d20b7be9)



 
 •	*Criar um script que valide se o serviço esta online e envie o resultado da validação para o seu diretório no nfs; O script deve conter - Data HORA + nome do serviço + Status + mensagem personalizada de ONLINE ou offline; O script deve gerar 2 arquivos de saida: 1 para o serviço online e 1 para o serviço OFFLINE.*
 

 - Para criar o script devemos estar dentro do nosso diretório que criamos anteriormente, neste caso o caminho seria ``` cd /mnt/nfs/gustavo ```. Estando dentro do diretório execute o comando ```nano service_status.sh``` para criar e abrir o arquivo do script. Dentro do arquivo, digite o script. O script criado para essa atividade pode ser observado a seguir:
   
 ```  
#!/bin/bash

service_name="Apache"
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

if systemctl is-active httpd; then
    echo "Data/Hora: $timestamp - $service_name - Serviço HTTPD - Status: o serviço está online" >> "/mnt/nfs/gustavo/httpd-online.txt"
else
   echo "Data/Hora: $timestamp - $service_name - Serviço HTTPD - Status: o serviço está offline " >> "/mnt/nfs/gustavo/httpd-offline.txt"
fi 

```
 Veja que, no exemplo acima, já indicamos que a operação deve criar no caminho do diretório indicado, e enviar dois arquivos em formato .txt com os resultados da verificação. Sendo um arquivo para o resultado online e outro para o resultado offline. Após salvar o arquivo devemos tornar o script executável com o comando ``` sudo chmod +x [nome do script]```, sendo, nesse caso, ```sudo chmod +x service_status.sh```, estando no diretório onde o script foi criado e ativado execute o comando ```./service_status.sh ``` para executá-lo. Caso esteja funcionando e o serviço esteja online o script deve criar o documento .txt de nome httpd-online.txt.


 •	Preparar a execução automatizada do script a cada 5 minutos.

 Para o agendamento da execução do script vamos utilizar o comando ```crontab -e```. Dentro do arquivo digite a linha ```*/5 * * * * /[caminho de onde está o script/nome do script]```. Em nosso caso, ficou dessa forma: ```*/5 * * * * /mnt/nfs/gustavo/service_status.sh```. Para fazer a confirmação de que o script  esta realizando a verificação do serviço offline é preciso interromper o Apache com o comando ``` service httpd status```. Aguardando alguns minutos para que o crontab continue a executar o script, poderemos ver a criação do arquivo httpd-offline.txt, que exibe os momentos em que o status do serviço estava offline, conforme imagens abaixo: 


 
![on off](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/3a2941c9-ba27-4959-bdbf-c4f524c33177)



![dando cat nos arquivos online e offline criados pelo script](https://github.com/Gustavopedoni1/Projeto-CompassUOL-LINUX_AWS/assets/157602238/3acfda3a-579e-4b45-b120-cb5b79b1a36e)

