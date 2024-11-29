# proj_times	- FEITO NO COMPILADOR MARS - DIOGO BERTOZI RA: 20150157 #

.data
   	msg_senha: .asciiz " \n\t  Insira a senha:  "
	.eqv senha 1234		
	msg_senha_invalida: .asciiz " \n\t  Senha invalida, tente novamente:  "
	menu1: .asciiz " \n\t 1 - Registrar uma Partida \n\t 2 - Printar Tabela \n\t 3 - Alterar dados \n\t 4 - Remover Partida \n\t 5 - Finaliza \n\t"
	digite: .asciiz " \n\t Digite sua escolha:  "
	msg_num_invalido: .asciiz " \n\t  Numero Invalido, tente novamente:  "
	msg_nome_time: .asciiz " \n\t  Digite nome de um time:  "
	msg_reg_time: .asciiz " \n\t  Digite o Time que jogara (0 -> 9):  "
	msg_reg_time2: .asciiz " \n\t  Digite nome de outro time:  "
	msg_times_iguais: .asciiz " \n\t  Time nao pode jogar contra ele mesmo, tente novamente  "
	msg_inicio_tabela: .asciiz " Times  |   | Jogos | Vitorias | Derrotas"
	msg_time: .asciiz " Time   "
	msg_: .asciiz "\n _________________________________________ \n"
	msgtab: .asciiz "\t"
	msglinha: .asciiz "\n"
	msgespaco: .asciiz "      "
	msg_digite_vencedor: .asciiz "\n\t Digite o numero do time vencedor: "
	msg_erro_vencedor: .asciiz "\n\t Vencedor Invalido, tente novamente "
	msg_finalistas: .asciiz "\n\t Os dois semi-finalistas sao: \n\t"
	msg_quartas_final: .asciiz "\n\t Os times das Quartas de Final sao:\n\t"
	msg_desclassificados: .asciiz "\n\t Times Desclassificados: \n\t"
	msg_rebaixados: .asciiz "\n\t Times Rebaixados: \n\t"
	msg_times_jogaram: .asciiz "\n\t Times ja jogaram um contra o outro \n\t"
	msg_t1_remove: .asciiz "\n\t Digite o numero do primeiro time que estava na partida \n\t"
	msg_t2_remove: .asciiz "\n\t Digite o numero do segundo time que estava na partida \n\t"
	msg_partida_nao_ocorreu: .asciiz "\n\t Partida ainda nao ocorreu \n\t"
	msg_partida_ocorreu: .asciiz "\n\t Partida removida com sucesso \n\t"
	msg_sla: .asciiz "     "
	msg_escolha: .asciiz "\n\tEscolha o numero do time q mudara o nome "
	msg_digite_nome: .asciiz "\n\tDigite o novo nome: "
	
										# vetores que guardam as informacoes da partida
	nomes_times:.space 160 				# 16 letra por time
	vet_jogos:    .word 0,0,0,0,0,0,0,0,0,0
	vet_vitorias: .word 0,0,0,0,0,0,0,0,0,0
	vet_derrotas: .word 0,0,0,0,0,0,0,0,0,0
	vet_aux_nomes:.word 0,1,2,3,4,5,6,7,8,9
	
										#vetores de flags, com uma posicao para cada possibilidade de partida
	verifica_jogos:.space 99 			#  ultimo jogo time 9 contra time 8 ((9 * 10) + 8)  
										#guarda informacao de se o jogo ja ocorreu ou nao
	verifica_vencedor:.space 98 		#  ultimo jogo time 9 contra time 8 ((9 * 10) + 8)  
										#guarda informacao de qual dos times ganhou a partida
	
.text 
.globl main

main: 

jal verificar_senha						# vai pra funcao que pede senha que eh 1234

jal registrar_times 					# vai pra funcao de registrar os times que sao necessarios para o funcionamento do programa

jal menu								# vai para o menu de escolhas

li $v0,10 	   							# finaliza o programa
syscall


verificar_senha:
	
	li $v0,4 # print mes				# mostra mensagem 
	la $a0,msg_senha
	syscall
	
do:
		li $v0,5 # le num				# le senha
		syscall
		move $s0,$v0 
		bne $s0, senha, senha_errada 	# se estiver errado, diz q senha errada e deixa tentar denovo
		j senha_certa
		
		
senha_errada:
		li $v0,4
		la $a0,msg_senha_invalida		# fala que errou senha, deixa tentar dnovo
		syscall
		j do
	
senha_certa: 
		jr $ra							# senha correta, vai pro menu

menu:

		li $t0,99
	
		lb $t1,verifica_jogos($t0)
		li $t0,0
		li $t9,1
		beq $t1,45,bubble_sort
		
		li $t9,0						# zera contador
		li $v0,4 # print mes
		la $a0,menu1					# printa mensagem
		syscall
		
		li $v0,4 # print mes
		la $a0,digite					# as mensagens do menu sao printadas
		syscall
			
menu_escolhas:
		li $v0,5 # le num
		syscall							# le a escolha do menu
		move $s0,$v0 #
		
		
		blt $s0,0,erro					# verifica se o numero digitado esta entre 
		bgt $s0,5,erro					# as possibilidades do menu
		
		beq $s0,1,registrar_partida 	# verifica em qual das funcoes o usuario quer entrar
		beq $s0,2,printar_tabela 
		beq $s0,3,alteracao  
		beq $s0,4,remover_partida 
		li $t0,0
		li $t9,1
		beq $s0,5,bubble_sort 
		
		
		jr $ra							# retorna a main

registrar_times:
	li $v0,4
	la $a0,msg_nome_time				# printa mensagem
	syscall
	

	li $v0,8 							# chama ler string 
	la $a0,nomes_times($t0)
	li $a1,16 							# tamanho da string em a1
	syscall
	
	addi $t0,$t0,16 					# adiciona um imetiato / inteiro
	addi $s1,$s1,1 
	bne $s1,10,registrar_times 			# se nao for 10, pula pro op 
	li $t0,0 							# carrega numero no registrador
	li $s1,0							# zera os regs
	
	jr $ra								# retorna para a main (pro jal)
	
	
erro:
	li $v0,4
	la $a0,msg_num_invalido				# printa mensagem
	syscall
	j menu_escolhas						# vai pro rotulo menu_escolhas
	
printar_tabela:
	li $v0,4
	la $a0,msg_inicio_tabela			# printa mensagem
	syscall
	
	li $v0,4
	la $a0,msglinha						# printa mensagem
	syscall

	li $s0,0							# zera o registrador
	
imprimir_tabela1:				   
	li $v0,4
    la $a0,msg_time						# printa mensagem
    syscall
	
    li $v0,1
    move $a0,$s0 						#printa numero do time
    syscall
	
	mul $s3,$s0,4 						# chega na posicao correta do nome do time
	
	lw $s2,vet_aux_nomes($s3)			# carrega o vetor auxiliar
	
	li $v0,4
    la $a0,msgtab						# espacamento
    syscall
    
    mul $s1,$s2,16						# chega na posicao correta do nome do time
    
    li $v0,4
    la $a0,nomes_times($s1)				# printa nome do time
    li $a1,16
    syscall
    
    mul $s1,$s0,4
    
    lw $t0,vet_jogos($s1)				# carrega vetor dos jogos

    li $v0,4
    la $a0,msgtab						# printa mensagem
    syscall
    
	li $v0,4
    la $a0,msgtab						# printa mensagem
    syscall
	
    li $v0,1
    move $a0,$t0						# printa inteiro
    syscall
	
	lw $t0,vet_vitorias($s1)			# carrega o vetor das vitorias
	
	li $v0,4
    la $a0,msgtab						# printa mensagem
    syscall
	
    li $v0,1
    move $a0,$t0						# printa inteiro
    syscall
	
	li $v0,4
    la $a0,msgespaco					# printa mensagem
    syscall
	
	lw $t0,vet_derrotas($s1)			# carrega o vetor das derrotas
	
	li $v0,4
    la $a0,msgtab						# printa mensagem
    syscall
	
    li $v0,1
    move $a0,$t0						# printa inteiro
    syscall
    
    li $v0,4
    la $a0,msg_							# printa mensagem
    syscall
    
    addi $s0,$s0,1
    bne $s0,10,imprimir_tabela1 		#se nao for 10, pula pro imprimir_tabela1
    
	beq $t9,1,fim_2						# flags que decidem caso o programa tenha que fazer algo em especifico
	beq $t9,2,aux_remove
	
    j menu								# jump menu

erro_reg_time:
	li $v0,4
	la $a0,msg_num_invalido				# print msg
	syscall
	
	j registrar_partida					# jump registrar_partida
	
erro_reg_time2:
	li $v0,4
	la $a0,msg_num_invalido				# print msg
	syscall
	
	j reg_time2
	
erro_vencedor:
	li $v0,4
	la $a0,msg_erro_vencedor			# print msg
	syscall
	
	j vencedor_escolha					# jump vencedor
	
alteracao:

	li $t0,0							# zera t0 para o funcionamento correto da funcao
	
imprime_times:
	
	li $v0,1
	move $a0,$t0						# imprime inteiro
	syscall
	
	li $v0,4
	la $a0,msg_sla						# printa mensagem			
	syscall
	
	mul $t1,$t0,16						# multiplica pelo tamanho de cada string
	
	li $v0,4
	la $a0,nomes_times($t1)				# print msg
	syscall
	
	addi $t0,$t0,1						# incrementa contador
	
	bne $t0,10,imprime_times			# repete as 10 vezes pra printar os 10 times
	
	volta:
	li $v0,4
	la $a0,msg_escolha					# print msg
	syscall
	
	li $v0,4
	la $a0,msg_digite_nome				# print msg
	syscall
	
	li $v0,5							# le o numero do time q sera substituido
	syscall
	
	move $s0,$v0				
	
	blt $s0,0,errou						# verifica se esse time existe
	bgt $s0,10,errou			
	
	mul $t1,$s0,16						# multiplica por 16 o numero do time para chegar no local correto do vetor de string
	
	li $v0,8
	la $a0,nomes_times($t1)				# le nome do time
	la $a1,12						
	syscall
	
	j menu								# jump menu
	
	
errou:

	li $v0,4
	la $a0,msg_num_invalido				# printa mensagem de num invalido
	syscall
	
	j volta								# print mensagem
	
	
times_iguais:
	li $v0,4
	la $a0,msg_times_iguais				# print mensagem
	syscall

	j registrar_partida					# jump rotulo registrar partida
	
times_jogaram:
	
	li $v0,4
	la $a0,msg_times_jogaram			# print mensagem
	syscall								# como os times ja jogaram, o usuario tem que tentar novamente

	j registrar_partida					# jump rotulo registrar partida

	
registrar_partida: 

    li $v0,4
    la $a0,msg_reg_time					# print mensagem
    syscall
	
	li $v0,5 							#func ler numero integrer
	syscall
	move $t1,$v0
	
	blt $t1,0,erro_reg_time				# verifica se o time digitado esta entre 0 e 9
	bgt $t1,9,erro_reg_time			

	
reg_time2:
	li $v0,4
    la $a0,msg_reg_time2				# print mensagem
    syscall
	
	li $v0,5 							#func ler numero integrer
	syscall
	move $t2,$v0
	
	blt $t2,0,erro_reg_time				# verifica se o numero esta entre 0 e 9
	bgt $t2,9,erro_reg_time			
	beq $t1,$t2,times_iguais			# verifica se os times sao iguais
	
							
	mul $t0,$t1,10						# calculo da posicao do flag
	add $t0,$t0,$t2
	
	lb $t3,verifica_jogos($t0)			# carrega em t3 o byte correto do vetor de flag
	beq $t3,1,times_jogaram				# se o flag dessa posicao for 1, os times ja jogaram, entao nao continua
	
	mul $t0,$t2,10						# calculo da posicao do flag
	add $t0,$t0,$t1
	
	lb $t3,verifica_jogos($t0)			# poe em t3 o flag da posicao dos times escolhidos
	beq $t3,1,times_jogaram				# se o flag dessa posicao for 1, os times ja jogaram, entao nao continua


vencedor_escolha:
	li $v0,4
    la $a0,msg_digite_vencedor			# print msg
    syscall
	
	li $v0,5 							# func ler numero integrer
	syscall
	move $t3,$v0 						# salva em t3 o time vencedor
	move $t5,$t3						# salva em t5 o time vencedor
	
	beq $t3,$t1,t1_vencedor				# verifica qual dos times granhou
	beq $t3,$t2,t2_vencedor
	j erro_vencedor						# jump pro erro vencedor
	
t1_vencedor:	
	mul $s1,$t1,4						# chega na posicao correta
	
	lw $t3,vet_jogos($s1)
	addi $t3,$t3,1 						# carrega e salva no vetor, incrementa em 1 o numero de jogos
	sw $t3,vet_jogos($s1)
	
	lw $t3,vet_vitorias($s1)
	addi $t3,$t3,1 						# carrega e salva no vetor, incrementa em 1 a vitoria do time
	sw $t3,vet_vitorias($s1)

	mul $s1,$t2,4
	
	lw $t3,vet_jogos($s1)
	addi $t3,$t3,1 						# carrega e salva no vetor, incrementa em 1 o numero de jogos
	sw $t3,vet_jogos($s1)
	
	lw $t3,vet_derrotas($s1)
	addi $t3,$t3,1 						# carrega e salva no vetor, incrementa em 1 a derrota do time
	sw $t3,vet_derrotas($s1)
	

	mul $t0,$t1,10						# multiplica por 10 o t1 e soma com o t2
	add $t0,$t0,$t2						# para chegar na posicao correta do vetor de flags formula ((t1*10)+t2)
	li $t3,1							# seta t3 como 1
	sb $t3,verifica_jogos($t0)  		# bota 1 na posicao do vetor auxiliar de flags onde houve partida
	
	mul $t0,$t2,10						# multiplica por 10 o t2 e soma com o t1
	add $t0,$t0,$t1						# para chegar na posicao correta do vetor de flags formula ((t2*10)+t1)
	li $t3,1							# seta t3 como 1
	sb $t3,verifica_jogos($t0)  		# bota 1 na posicao do vetor auxiliar de flags onde houve partida
	
	mul $t0,$t1,10						# multiplica por 10 o t1 e soma com o t2
	add $t0,$t0,$t2						# para chegar na posicao correta do vetor de flags formula ((t1*10)+t2)
	sb $t5,verifica_vencedor($t0)		# bota o numero do time vencedor na posicao do vetor auxiliar de flags

	mul $t0,$t2,10						# multiplica por 10 o t2 e soma com o t1
	add $t0,$t0,$t1						# para chegar na posicao correta do vetor de flags formula ((t1*10)+t2)
	sb $t5,verifica_vencedor($t0)
	
	li $t0,99
	
	lb $t1,verifica_jogos($t0)
	addi $t1,$t1,1
	sb $t1,verifica_jogos($t0)
	

	j menu								# retorna ao menu



t2_vencedor:

	mul $s1,$t2,4			  			# chega na posicao correta
	
	lw $t3,vet_jogos($s1)
	addi $t3,$t3,1 						#carrega e salva no vetor, incrementa em 1 o numero de jogos
	sw $t3,vet_jogos($s1)
	
	lw $t3,vet_vitorias($s1)
	addi $t3,$t3,1 						#carrega e salva no vetor, incrementa em 1 a vitoria do time
	sw $t3,vet_vitorias($s1)

	mul $s1,$t1,4						# chega na posicao correta
	
	lw $t3,vet_jogos($s1)
	addi $t3,$t3,1 						#carrega e salva no vetor, incrementa em 1 o numero de jogos
	sw $t3,vet_jogos($s1)
	
	lw $t3,vet_derrotas($s1)
	addi $t3,$t3,1 						#carrega e salva no vetor, incrementa em 1 a derrota do time
	sw $t3,vet_derrotas($s1)
	
	mul $t0,$t1,10						# multiplica por 10 o t1 e soma com o t2
	add $t0,$t0,$t2						# para chegar na posicao correta do vetor de flags formula ((t1*10)+t2)

	li $t3,1							# seta t3 como 1
	sb $t3,verifica_jogos($t0) 		 # bota 1 na posicao do vetor auxiliar de flags onde houve partida
	
	mul $t0,$t2,10						# multiplica por 10 o t2 e soma com o t1
	add $t0,$t0,$t1						# para chegar na posicao correta do vetor de flags formula ((t2*10)+t1)
	li $t3,1							# seta t3 como 1
	sb $t3,verifica_jogos($t0)  		# bota 1 na outra posicao do vetor auxiliar de flags onde houve partida
	
	mul $t0,$t1,10
	add $t0,$t0,$t2		
	sb $t5,verifica_vencedor($t0)
	
	mul $t0,$t2,10
	add $t0,$t0,$t1		
	sb $t5,verifica_vencedor($t0)
	
	li $t0,99
	
	lb $t1,verifica_jogos($t0)
	addi $t1,$t1,1
	sb $t1,verifica_jogos($t0)
	
	j menu							    # pula pro menu

bubble_sort: 

	li $t1,0   						    # zera t1

	for_fora:						    # bubble sort padrao
		lw $s0,vet_vitorias($t1)        # pega elemento de uma casa antes
		addi $t1,$t1,4    			    # avanca o vetor
		lw $s1,vet_vitorias($t1)        # carrega mais uma casa
		bne $t1,40,continua  		    # faz enquanto menor que 40
		addi $t0,$t0,1    			    # mais 1 pro for de fora
		bne $t0,10,bubble_sort   	    # atualizacao do laco
		
		j fim						    # pula pro fim
			
	for_dentro:							#bubble sort padrao
	
		addi $t1,$t1,-4					# volta o vetor em 4
		lw $s2,vet_vitorias($t1)		# soma 1 no valor de quantos jogos aquele time ganhou
		lw $s3,vet_jogos($t1)			# soma 1 no valor de quantos jogos aquele time jogou
		lw $s4,vet_derrotas($t1)	    # soma 1 no valor de quantos jogos aquele time perdeu
		lw $s5,vet_aux_nomes($t1)		# soma 1 no valor do vetor auxiliar de flags usado nas funcoes de verificacao

		addi $t1,$t1,4
		
		lw $t2,vet_vitorias($t1)		# carregamento dos vetores
		lw $t3,vet_jogos($t1)
		lw $t4,vet_derrotas($t1)
		lw $t5,vet_aux_nomes($t1)
		
		sw $s2,vet_vitorias($t1)		# carregamento dos vetores
		sw $s3,vet_jogos($t1)
		sw $s4,vet_derrotas($t1)
		sw $s5,vet_aux_nomes($t1)
		
		addi $t1,$t1,-4					# volta o vetor em 4
		
		sw $t2,vet_vitorias($t1)		# carregamento dos vetores
		sw $t3,vet_jogos($t1)
		sw $t4,vet_derrotas($t1)
		sw $t5,vet_aux_nomes($t1)
		
		addi $t1,$t1,4
		
		j for_fora  		

		continua:					   # continua pra fazer com todo o vetor
		blt $s0,$s1,for_dentro         # acha o menor
		j for_fora      			  
		
	 
fim:

	li $v0,4
	la $a0,msg_t1_remove
	syscall
	
	li $t9,1						   # seta flag para encerrar programa apos printar a tabela
	j printar_tabela
	
fim_2:
	li $t0,0						   # zera o t0
	
	li $v0,4
	la $a0,msg_finalistas			   # printa mensagem 
	syscall
	
semifinalistas:
	lw $t1,vet_aux_nomes($t0)		   # carrega o vetor auxiliar dos nomes
		
	mul $t1,$t1,16					   # multiplica pelo tamanho do nome de cada time
	li $v0,4
	la $a0,nomes_times($t1)			   # print o nome dos semifinalistas
	syscall							   # (como a tabela ja esta ordenada, ja estao na ordem certa os times
	
	li $v0,4
	la $a0,msgtab					   # print de espacamento
	syscall
	
	addi $t0,$t0,4					   # passa pro proximo time do vetor
	bne $t0,8,semifinalistas		   # repete 2 vezes (4+4 = 8)
	
	li $v0,4
	la $a0,msg_quartas_final		   # print da msg
	syscall
	
quartas_final:
	lw $t1,vet_aux_nomes($t0)		   # carrega o vetor auxiliar dos nomes
	
	mul $t1,$t1,16					   # multiplica pelo tamanho do nome de cada time
	li $v0,4
	la $a0,nomes_times($t1)			   # print o nome dos que estao nas quartas de final
	syscall
	
	li $v0,4
	la $a0,msgtab					   # print o nome dos que estao nas quartas de final
	syscall
	
	addi $t0,$t0,4
	bne $t0,24,quartas_final   		   # repete 24/4 vezes (6)
	
	li $v0,4
	la $a0,msg_desclassificados		   # print da mensagem dos desclassificados
	syscall

desclassificados:

	lw $t1,vet_aux_nomes($t0)		   # carrega o vetor auxiliar dos nomes
	
	mul $t1,$t1,16
	li $v0,4
	la $a0,nomes_times($t1)			   # print o nome dos que estao desclassificados
	syscall
	
	li $v0,4
	la $a0,msgtab					   # print espaco na tela
	syscall
	
	addi $t0,$t0,4
	bne $t0,32,desclassificados		   # repete 32/4 vezes (8) 
	
	li $v0,4
	la $a0,msg_rebaixados			   # print da mensagem dos rebaixados
	syscall
	
rebaixados:	
	lw $t1,vet_aux_nomes($t0)		   # carrega o vetor auxiliar dos nomes
	
	mul $t1,$t1,16
	li $v0,4
	la $a0,nomes_times($t1)			   # print o nome dos times rebaixados
	syscall
	
	li $v0,4
	la $a0,msgtab					   # print espaco na tela
	syscall
	
	addi $t0,$t0,4
	bne $t0,40,rebaixados			   # repete as ultimas duas vezes para interar 40/4 vezes (10 times) 
	
	li $v0,10						   # finaliza o programa
	syscall
	
	
remover_partida:
	
	li $t9,2			        		# seta o flag para que o programa va para aux_remove apos printar tabela
	j printar_tabela					#printar tabela
	
	aux_remove:
			
		li $v0,4
		la $a0,msg_t1_remove			# pergunta time 1
		syscall
		
		li $v0,5 # le num				# le o time 1
		syscall
		move $s1,$v0 #
		
		li $v0,4
		la $a0,msg_t2_remove			# pergunta time 2
		syscall
		
		li $v0,5 # le num				# le o time 2
		syscall
		move $s2,$v0 
			
		mul $s3,$s1,10					# multiplica por 10 o s1 e soma com o s2
		add $s3,$s3,$s2					# para chegar na posicao correta do vetor de flags formula ((t1*10)+t2)
		lb $s4,verifica_jogos($s3)		# carrega o valor que foi salvo para saber se esses times ja jogaram ou nao (0 ou 1)
		beq $s4,0,partida_nao_ocorreu	# 0 -> partida_nao_ocorreu
		beq $s4,1,partida_ocorreu		# 1 -> partida_ocorreu
		
partida_nao_ocorreu:
	
	li $v0,4
	la $a0,msg_partida_nao_ocorreu	#pergunto time 2
	syscall
	
	li $s6,999999					#numero grande para causar um delay e manter a mensagem um pouco na tela
	
	delay:
		addi $s6,$s6,-1				# vai removendo 1 dos 999999
		bne $s6,0,delay				# ate dar 0
		
	j menu							# retorna ao men
	
partida_ocorreu: 
							
	mul $t0,$s1,10					# multiplica por 10 o s1 e soma com o s2
	add $t0,$t0,$s2					# para chegar na posicao correta do vetor de flags formula ((t1*10)+t2)
	
	
	lb $t3,verifica_vencedor($t0)	# poe em t3 a o valor salvo na posicao ((t1*10)+t2)
	
	
	beq $t3,$s1,s1_vencedor			# se o numero em t3 for o mesmo do s1, entao ele eh o vencedor
	
	mul $s4,$s2,4					# chega na posicao correta do vetor e remove 1 
	
	lw $s5,vet_vitorias($s4)		# do contador de vitorias do time que venceu
	addi $s5,$s5,-1
	sw $s5,vet_vitorias($s4)		# salva devolta no vetor
	
	lw $s5,vet_jogos($s4)			# chega na posicao correta do vetor e remove 1 
	addi $s5,$s5,-1					# do contador jogos jogados de um dos times
	sw $s5,vet_jogos($s4)			# salva devolta no vetor
	
	mul $s4,$s1,4					# chega na posicao correta do vetor e remove 1 
	lw $s5,vet_derrotas($s4)		# do contador de derrotas do time que perdeu 
	addi $s5,$s5,-1
	sw $s5,vet_derrotas($s4)		# salva devolta no vetor
	
	lw $s5,vet_jogos($s4)			# chega na posicao correta do vetor e remove 1 
	addi $s5,$s5,-1					# do contador de derrotas do time que perdeu 
	sw $s5,vet_jogos($s4)			# salva devolta no vetor

	li $t4,0
	sb $t4,verifica_jogos($t0)      ## zera o vetor de flag na posicao que foi removida
	sb $t4,verifica_vencedor($t0)   ## zera o vetor de flag na posicao que foi removida
	
	mul $s7,$s2,10					# multiplica por 10 o s1 e soma com o s2
	add $s7,$s7,$s1
	
	sb $t4,verifica_jogos($s7)      ## zera o vetor de flag na posicao que foi removida
	
	sb $t4,verifica_vencedor($s7)   ## zera o vetor de flag na posicao que foi removida
	
	li $s7,99
	lb $t4,verifica_jogos($s7)
	addi $t4,$t4,-1
	sb $t4,verifica_jogos($s7)

	j delay_concluido				#vai pro rotulo do delay

delay_concluido:

	li $v0,4
	la $a0,msg_partida_ocorreu		#faz o delay
	syscall
	
		li $s6,999999
	
	delay2:
		addi $s6,$s6,-1
		bne $s6,0,delay2
	
	j menu							# volta pro menu
		
s1_vencedor:
	
	mul $s4,$s1,4					# repete o mesmo feito em "partida_ocorreu"
	lw $s5,vet_vitorias($s4)		# porem dessa vez faz o caso do s1 ser o vencedor, e nao do s2
	addi $s5,$s5,-1					
	sw $s5,vet_vitorias($s4)		
	
	lw $s5,vet_jogos($s4)
	addi $s5,$s5,-1
	sw $s5,vet_jogos($s4)
	
	mul $s4,$s2,4
	lw $s5,vet_derrotas($s4)
	addi $s5,$s5,-1
	sw $s5,vet_derrotas($s4)
	
	lw $s5,vet_jogos($s4)
	addi $s5,$s5,-1
	sw $s5,vet_jogos($s4)
	
	mul $t0,$s1,10
	add $t0,$t0,$s2
	
	li $t4,0
	sb $t4,verifica_jogos($t0)      ## zera o vetor de flag na posicao que foi removida
	sb $t4,verifica_vencedor($t0)   ## zera o vetor de flag na posicao que foi removida
	
	mul $s7,$s2,10					# multiplica por 10 o s1 e soma com o s2
	add $s7,$s7,$s1
	
	sb $t4,verifica_jogos($s7)      # zera o vetor de flag na posicao que foi removida
	
	sb $t4,verifica_vencedor($s7)   # zera o vetor de flag na posicao que foi removida
	
	li $s7,99						# seta na posicao 99 (contador total de partidas)
	lb $t4,verifica_jogos($s7)		# carrega
	addi $t4,$t4,-1					# remove 1 do contador total de partidas
	sb $t4,verifica_jogos($s7)		# salva

	j delay_concluido				#vai pro rotulo do delay