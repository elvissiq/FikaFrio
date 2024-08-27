#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TOTVS.ch"

//--------------------------------------------------------
/*/ Rotina OMSA200
  Ponto de entrada OS200EST

   Ap�s altera��o da carga. Bot�o "Editar",
   alterar quantidade.
    
   Implementado para:
     - Enviar Altera��o de Carga para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
//--------------------------------------------------------
User Function OM200EST()
  Local oFusion := PCLSFUSION():New()
  Local nPosPed := aScan(aHeader,{|x| AllTrim(x[2]) == "DAI_PEDIDO"})

  oFusion:AltCarga("N",{aCols[n][nPosPed]},TRB->TRB_RECNO)
Return
