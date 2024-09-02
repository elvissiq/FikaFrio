#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EMP650    � Autor � Ricardo Rotta      � Data �  02/09/14   ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de Entrada no momento da abertura da OP para gerar   ���
���          � empenho no almoxarifado                                    ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function EMP650()

Local _aArea   := GetArea()
Local _nPosLc  := aScan(aHeader,{|x| AllTrim(x[2])=="D4_LOCAL"})
Local _nPosCd  := aScan(aHeader,{|x| AllTrim(x[2])=="G1_COMP"})
Local _cLocPad := SuperGetMv("MV_XLOCPRD",.F.,"90")
Local _nI      := 1
Local cTipo    := CriaVar("B1_TIPO", .F.)
For _nI := 1 To Len(aCols)
	cTipo := Posicione("SB1", 1, xFilial("SB1", 1, xFilial("SB1")+aCols[_nI,_nPosCd]), "B1_TIPO")
	If !IsProdMOD(aCols[_nI,_nPosCd],.T.)
		If cTipo <> "PI"
			aCols[_nI][_nPosLc] := _cLocPad
		Endif
	Endif
Next _nI
RestArea(_aArea)
Return
