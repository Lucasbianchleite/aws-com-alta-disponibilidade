##para criarmos os gurpos de segurança, vamos precisar definir quantos vamos precisar
>EC2
>RDS-EC2
>BASTION RULES


ficando a tabela assim
| nome        | Regras de entrada      | Regras de saída              | Motivo                                                      |
|--------------|----------|----------------------|------------------------------------------------------------|
| DB-for-EC2S | xxxxxxxxxxxxxxxx| tipo:MYSQL/Aurora Protocolo:TCP porta:3306 destino: grupo de segurança das ec2   | as ec2 conseguirem acessar o security group |
| bastion-rules   | todo o trafego | todo o trafego | conseguir fazer o jum do ssh                          |
| ec2-rules  |   | EFS-1-subnet-private  | Alocar um mount target do EFS para comunicação com a EC2   |

após isso, configuramos nosso security group
