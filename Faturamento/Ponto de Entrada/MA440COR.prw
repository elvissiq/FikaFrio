//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
  
/*/{Protheus.doc} MA440COR 
Ponto-de-Entrada: MA440COR - Alterar cores do browse do cadastro de status do Pedido de Venda
@author Elvis Siqueira
@since 25/11/2021
@version 1.0
    @return aCores(vetor) Array com as cores para o "browse"
    @example
    u_MA440COR()
    @obs 
/*/
 
User Function MA440COR()

// -- A função "fn410Vld" está no programa "MA410COR"

Local aCores := { { "(U_fn410Vld('C'))", "BR_PINK"},;        // Bloqueado por credito
				  { "(U_fn410Vld('E'))", "BR_MARROM"},;      // Bloqueado por estoque
	              { "(!Empty(C5_NOTA) .Or. C5_LIBEROK == 'E') .And. Empty(C5_BLQ) .and. (U_fn410Vld('L')) ","DISABLE" },;    // Pedido Encerrado            
  				  { "!Empty(C5_LIBEROK).And.Empty(C5_NOTA).And. Empty(C5_BLQ) .and. (U_fn410Vld('L')) "    ,"BR_AMARELO"},;  // Pedido Liberado
				  { "C5_NOTA == 'XXXXXXXXX' .and. C5_LIBEROK == 'S' .and. Empty(C5_BLQ) ","BR_AZUL_CLARO" },; // Pedido Eliminado Residuo
				  { "C5_BLQ == '1'"    , "BR_AZUL"},;        // Pedido Bloquedo por regra
				  { "C5_BLQ == '2'"    , "BR_LARANJA"},;     // Pedido Bloquedo por verba					
				  { "(U_fn410Vld('W'))", "BR_BRANCO"},;      // Bloqueado por WMS
				  { "Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ)",'ENABLE' },;  //Pedido em Aberto     
				  { "C5_BLQ == '9'"    , "BR_PRETO"}}        // Pedido bloqueado por regra (desconto/acrescimo)
		
Return aCores
 