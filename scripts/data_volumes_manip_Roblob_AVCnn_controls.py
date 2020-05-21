#!/bin/bash
# -*- coding: utf-8 -*-
import sys  
reload(sys)
sys.setdefaultencoding('utf8')
import os
import numpy as np
import nibabel as nb
import pandas as pd
import glob
#from IPython.core.display import display, HTML
#display(HTML("<style>.container { width:100% !important; }</style>"))
import csv


#Mise en formes des volumes des volumes extraits
Labels_RobLob = pd.DataFrame(columns=['Numero Labels','Legende'], index=range(12))
Numero_Labels = [1,2,3,4,5,11,12,13,14,15,25,35]

#legende par ordre croissant des Labels !!!! Pour la matiere grise, et pour la matiere blanche.
Legends_GM=['Right_F','Right_P','Right_O','Right_T','Right_Ventricles_Th_Pons','Left_F','Left_P','Left_O','Left_T','Left_Ventricles_Th_Pons','Right_Cerebellum','Left_Cerebellum']
Legends_WM=['Right_F','Right_P','Right_O','Right_T','Left_F','Left_P','Left_O','Left_T','Right_Cerebellum','Left_Cerebellum']
Legends = []
Tissue_Type=['grey_matter','white_matter']
tissue_prefix=['WM','GM']
N_labels=12

###PARAMETRES A MODIFIER PAR l'UTILISATEUR
path_database='/neurospin/grip/protocols/MRI/MaximeDeMalherbe_AVCnn_2017/AVCnn_2017_RobLob/subjects' #CHEMIN OU SE TROUVE LES SUJETS DANS
subjects_list='/neurospin/grip/protocols/MRI/MaximeDeMalherbe_AVCnn_2017/Script_RobLob/Roblob_pipeline_controls/sub_list_controls.txt' #LISTE DU FICHIER TEXTE DES NOM DE DOSSIER DES SUJETS 'anat1_.....'
save_dir_name='Roblob/resultats_volumes' 
########FIN DU BLOC DE PARAMETRES


#ouverture liste des sujets.
sujets = open(subjects_list).read().split()

#####Chargement des fichiers de volumes en sortie de RobLob, mise en forme d'un tableau de volumes lobaires Gris/Blanc par sujet 
for s in sujets:
    for tissue in Tissue_Type:
        
        if tissue == 'grey_matter':
            Legends = Legends_GM
        else:
            Legends = Legends_WM
            
        Volume_espace_natif_file_ = pd.read_csv(glob.glob(os.path.join(path_database,s,save_dir_name,'mni_to_native_'+tissue+'*cleaned.csv'))[0],delim_whitespace=True)#chargement des donné issue de la derniere etape
        #de RobLob
        Volume_espace_natif_file_.drop('point_count',axis=1, inplace=True) #delete the column without having to reassign df (a mon avis faire la copie)
        Volume_espace_natif_file_.columns = ['Lobe','Volume (mm³)']
        for ind,legend in zip(                       range(len(Volume_espace_natif_file_['Lobe'])),range(len(Legends))                              ):

            Volume_espace_natif_file_.loc[ind,'Lobe'] = tissue+'_'+Legends[legend]
            Volume_espace_natif_file_.to_csv(os.path.join(path_database,s,save_dir_name,tissue+'_'+s+'_volume_natif_cleaned.csv'),index=False)

        
#concatenation des deux tableaux
    volume_grey_matter_lobe = pd.read_csv(os.path.join(path_database,s,save_dir_name,'grey_matter_'+s+'_volume_natif_cleaned.csv'))
    volume_white_matter_lobe = pd.read_csv(os.path.join(path_database,s,save_dir_name,'white_matter_'+s+'_volume_natif_cleaned.csv'))
    frames = [volume_grey_matter_lobe, volume_white_matter_lobe]
    Volume_espace_natif_total = pd.concat(frames)
    Volume_espace_natif_total.to_csv(os.path.join(path_database,s,save_dir_name,s+'_volume_lobaire_total_espace_natif_cleaned.csv'),index=False)

#header du CSV qui regroupe tous les volumes lobaire de tous les sujets
header = ['sujet','grey_Right_F','grey_Right_P','grey_Right_O','grey_Right_T','grey_Right_Ventricles_Th_Pons','grey_Left_F','grey_Left_P','grey_Left_O'
         ,'grey_Left_T','grey_Left_Ventricles_Th_Pons','grey_Right_Cerebellum','grey_Left_Cerebellum','white_Right_F','white_Right_P','white_Right_O','white_Right_T','white_Left_F'
         ,'white_Left_P','white_Left_O','white_Left_T','']

#Creation d'un CSV qui regroupes tous les sujets
with open(os.path.join(path_database,'controls_volume_lobaire_all_subjects_RobLob2.csv'),'w') as volume_lobaire_all_subjects:
    writter = csv.DictWriter(volume_lobaire_all_subjects,fieldnames=header)
    writter.writeheader()
    
#derniere etape: ecriture pour chaque sujet des volumes dans le CSV total et conversion en xlsx des volumes natif du sujet
for s in sujets:
    volume_lobaire_natif_du_sujet = pd.read_csv(os.path.join(path_database,s,save_dir_name,s+'_volume_lobaire_total_espace_natif_cleaned.csv'))
    with open(os.path.join(path_database,'controls_volume_lobaire_all_subjects_RobLob2.csv'),'a') as volume_lobaire_all_subjects:
        
        volume_lobes = list(volume_lobaire_natif_du_sujet['Volume (mm³)'])
        ligne = [s]+volume_lobes
        writter = csv.writer(volume_lobaire_all_subjects)
        writter.writerow(ligne)

    xlsx_volume_volume_lobaire_natif = volume_lobaire_natif_du_sujet.to_excel(os.path.join(path_database,s,save_dir_name,s+'_volume_lobaire_total_espace_natif_cleaned.xlsx'),sheet_name='Volume lobaire espace natif',index=False)

#Conversion en xlsx du CSV regroupant les volumes lobaire dans l'espace natif de tous les sujets
volume_lobaire_all_subjects_df = pd.read_csv(os.path.join(path_database,'controls_volume_lobaire_all_subjects_RobLob2.csv'))
volume_lobaire_all_subjects_df.to_excel(os.path.join(path_database,'controls_volume_lobaire_all_subjects_RobLob2.xlsx'),sheet_name = 'Volume de tous les sujets',index=False)
