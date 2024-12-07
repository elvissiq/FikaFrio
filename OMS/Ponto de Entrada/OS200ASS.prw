#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//----------------------------------------------------------
/*/ Rotina OMSA200

  Ponto de entrada OS200ASS

   Após gravação da manutencao da carga.
   
   Implementado para:
     - Enviar alteração da Carga para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
//--------------------------------------------------------
User Function OS200ASS() //-- rotinas especificas... 
  Alert("OS200ASS")
  Alert(DAK->DAK_COD)
  Alert(SC5->C5_NUM)
  Alert(Len(aCols))
  MemoWrite("c:\temp\Acols.txt",Varinfo("Acols ",aCols))
Return
