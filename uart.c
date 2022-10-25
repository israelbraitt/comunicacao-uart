#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>	//Usado para UART
#include <fcntl.h>	//Usado para UART
#include <termios.h>	//Usado para UART

void uart_tx(char* tx_string, int uart_filestream); //Funcao para envio de dados
void uart_rx(int uart_filestream, char* dado); //Funcao para recebimento de dados

int main(){
	int sensor=0; //Armazena a opcao do sensor selecionado pelo usuÃ¡rio
	int comando=0; //Armazena a opcao de comando selecionado pelo usuÃ¡rio
 	unsigned char comandoResposta[9]; //Armazena o comando de resposta lido pelo rx

	char situacao[]="0x03"; //codigo da situacao aual do sensor.
	char temperatura[]="0x04"; //codigo da medida de temperatura.
	char umidade[]="0x05";//codigo da medida de umidade.	
    
//-----------------------------------------------------------------------------------------------------------------------------------
//Configuracao da UART
   
       //Abertura do arquivo da UART
	int uart_filestream = -1;
	uart_filestream = open("/dev/serial0", O_RDWR | O_NOCTTY | O_NDELAY);	//Abre em modo escrita/leitura bloqueado
	if (uart_filestream == -1){
		printf("\nErro: nao eh posssivel abrir o arquivo da UART.\n");
	}
	
	printf("\nRequisicao sendo enviada. Aguarde uns instantes\n"); 
	uart_tx("0x02",uart_filestream);
        uart_tx("0x04",uart_filestream);
	printf("Dado enviado: 0x020x04\n");
		   		
	char dado[9];
	int rx_length, aux = 0;
	
	if (uart_filestream != -1){
		while(aux < 8){
			rx_length = read(uart_filestream, (void*)comandoResposta, 8); //Filestream, buffer para armazenar, numero maximo de bytes lidos
			aux += rx_length;
			strcat(dado, comandoResposta);
		}
		
			strcpy(comandoResposta, dado);
		
		 
		
		if (rx_length < 0){
			printf("\nOcorreu um erro na leitura de dados");
		}
		else if (rx_length == 0){
			printf("\nNenhum dado lido");
		}
		else{
			//Byte recebido
			comandoResposta[rx_length] = '\0';
			printf("\n\nDado recebido: %s", comandoResposta);
			if(strcmp(comandoResposta, "0x020x04")==0){
		     	printf("\nUart funcionando!!!!\n");
		  	}
		}
	}
	else{
		printf("\nFalha na abertura do arquivo");
	}
	
	//Fecha a conexao com a UART
	close(uart_filestream); 
	return 0;
}
//Funcao que envia os dados na UART
void uart_tx(char* tx_string, int uart_filestream){
	if (uart_filestream != -1){//Se abriu o arquivo da UART
		write(uart_filestream, tx_string, strlen(tx_string)); //Filestream,mensagem enviada,tamanho da mensagem
	}	
	else{
		printf("\nFalha na abertura do arquivo");
	}
}

