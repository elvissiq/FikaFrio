//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
  
/*/{Protheus.doc} MA410LEG 
Ponto-de-Entrada: MA410LEG - Alterar textos da legenda de status do Pedido de Venda
@author Elvis Siqueira
@since 19/11/2021
@version 1.0
    @return aNovLeg(vetor) Array com a legenda.
    @example
    u_MA410LEG()
    @obs 
/*/
 
User Function MA410LEG()
    Local aNovLeg  := PARAMIXB
    
    aNovLeg := { {'ENABLE'          ,'Pedido de Venda em aberto' },;
                 {'DISABLE'         ,'Pedido de Venda encerrado' },;
                 {'BR_AZUL_CLARO'   ,'Pedido Eliminado Residuo ' },;
                 {'BR_AMARELO'      ,'Pedido de Venda liberado'  },;
                 {'BR_AZUL'         ,'Pedido de Venda com Bloqueio de Regra' },;
                 {'BR_LARANJA'      ,'Pedido de Venda com Bloqueio de Verba' },; 
                 {'BR_PINK'         ,'Pedido de Venda com Bloqueio de Crédito' },;
                 {'BR_MARROM'       ,'Pedido de Venda com Bloqueio de Estoque' },;
                 {'BR_BRANCO'       ,'Pedido de Venda com Bloqueio de WMS' },;
                 {'BR_PRETO'        ,'Pedido de Venda com Bloqueio de Regra (Desconto/Acrescimo)' }}

Return aNovLeg
 