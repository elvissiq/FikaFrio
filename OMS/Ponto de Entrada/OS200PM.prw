#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//----------------------------------------------------------
/*/ Rotina OMSA200
  Ponto de entrada OS200PM

   Após gravação da manutencao da carga.
   
   Implementado para:
     - Enviar alteração da Carga para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
//--------------------------------------------------------
User Function OS200PM()
  Local lEnvFusion := .F. 
  Local nId        := 0
  Local oFusion    := PCLSFUSION():New()
  Local aPedido    := {}

  For nId := 1 To Len(aCols)
      If aCols[nId][Len(aHeader) + 1]
         lEnvFusion := .T.

         aAdd(aPedido, aCols[nId][04])
      EndIf   
  Next

  If lEnvFusion
     oFusion:AltCarga("S",aPedido,0)                  // se forma carga, pedido e recno
  EndIf
Return
