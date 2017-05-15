#!/bin/bash
#RobLob pour AVCnn: Dhaif BEKHA. 
#Ref: Toro & al.
####Launcher: 

#RobLob entrée: Anatomie T1 sans le crane, fichier de lesions.
#RobLob sortie: fichier lobaire de matiere blanche, de matiere grise dans l'espace natif, 
#		fichier xlsx regroupant les volumes lobaire dans le dossier du sujet
#		fichier xlsx regroupant les volumes de tous les sujets.



###--Paramètres: a modifier par l'utilisateur---####
subject_directory=/neurospin/grip/protocols/MRI/MaximeDeMalherbe_AVCnn_2017/AVCnn_2017_RobLob/subjects #nom du dossier ou se trouve tous les sujets
#subject_list=(anat1_nc110193-2604_20110427_02 anat1_ib110200-2622_20110504_02 anat1_ct110201-2625_20110504_02 anat1_eb110217-2652_20110518_02 anat1_gk110258-2688_20110608_02 anat1_al110271-2701_20110615_02	anat1_em090307-2775_20110824_02	anat1_cd090095-2774_20110824_02	anat1_sl100362-2792_20110907_02	anat1_ag110427-2845_20111026_02	anat1_nn110428-2846_20111026_02 anat1_at110408-2860_20111116_02	anat1_xc120030-2917_20120125_02	anat1_rp120164-3109_20120523_02	anat1_ab120161-3150_20120613_02	anat1_cg120322-3227_20120711_02	anat1_cm120095-3553_20130206_02 anat1_cb130208-3716_20130417_02	anat1_cd120206-3762_20130515_02	anat1_mp120048-3787_20130529_02	anat1_sb120208-3805_20130605_02	anat1_ln120402-3978_20130911_02	anat1_kf130380-3979_20130911_02 anat1_ls130404-4005_20130925_02	anat1_sv120315-4007_20130925_02	anat1_ep120255-4070_20131106_02	anat1_ea130507-4071_20131106_02	anat1_ml130538-4087_20131120_02	anat1_hd130539-4088_20131120_02) #liste des sujets a traiter, chaque nom séparé par un espace simple


subject_list=(anat1_cb130208-3716_20130417_02)
nb_subjects=${#subject_list[@]} #nombre de sujets NE PAS TOUCHER 

atlas_root=/i2bm/local/fsl/data/standard #dossier ou se trouve les atlas de references (MNI...) pour FSL NE PAS TOUCHER
atlas_reference_recalage=$atlas_root/MNI152_T1_2mm_brain.nii.gz #atlas de reference dans l'espace normé pour le recalage avec flirt NE PAS TOUCHER
atlas_reference_normalisation=$atlas_root/MNI152_T1_1mm_brain.nii.gz #atlas de reference dans l'espace normé pour la normalisation avec fnirt NE PAS TOUCHER
brain_masque_reference=$atlas_root/MNI152_T1_1mm_brain_mask.nii.gz #masque du cerveau de reference dans le MNI. NE PAS TOUCHER
atlas_lobaire=/media/db242421/db242421_data/Bac_a_sable/test_en_tout_genre/FSL_python_volumetrie/subjects/anat1_ab120432-3325_20120919_02/atlas_RobLob/labels_RobLob_withcbl.nii.gz #CHEMIN OU SE TROUVE l'ATLAS LOBAIRE RobLob (regarde dans le tuto de Pauline Garzon)

common_path=t1mri/default_acquisition/default_analysis/segmentation #chemin commun selon l'architecture BV, pour acceder au données interessante NE PAS TOUCHER
save_directory_name=Roblob #dossier ou seront sauvegarder les fichiers de la methode de calcul RobLob

script_bash=/neurospin/grip/protocols/MRI/MaximeDeMalherbe_AVCnn_2017/Script_RobLob/Roblob_pipeline_controls #CHEMIN DU DOSSIER OU SE TROUVE LES SCRIPTS RobLob_launcher, roblob_avcnn_etape_2.sh, Roblob_avcnn_etape1.sh
script_python=/neurospin/grip/protocols/MRI/MaximeDeMalherbe_AVCnn_2017/Script_RobLob/Roblob_pipeline_controls #CHEMIN DU DOSSIER OU SE TROUVE LE SCRIPTS data_volumes_manip_RobLob_AVCnn.py
batch_directory=/neurospin/grip/protocols/MRI/MaximeDeMalherbe_AVCnn_2017/Script_RobLob/Roblob_pipeline_controls
batch_instruction_directory=/neurospin/grip/protocols/MRI/MaximeDeMalherbe_AVCnn_2017/AVCnn_2017_RobLob/subjects/spm_batch/roblob
####---Fin du bloc de parametres---####



echo "---ALGORITHME ROBLOB_AVCnn EN COURS....-----"
echo $(date) 

echo "---ETAPE 1/2....---"
source $script_bash/Roblob_avcnn_etape1_controls.sh #premiere etape: normalisation dans le MNI, calcul de la transfo direct et de bijection
echo "---FIN ETAPE 1...---"

echo "---ETAPE 2/2 PARTIE 1....---"
source $script_bash/roblob_avcnn_etape_2_partie1_controls.sh #fabrication des fichier images de lobe de matiere grise et blanche dans l'espace natif, calcul des volumes dans l'espace natif
echo "---FIN ETAPE 2/2 PARTIE 1....---"

#execution du script matlab qui va fabriquer les batchs individuels
matlab-R2016a -nojvm -nodisplay -nosplash -r "run('$batch_directory/recalage_Skull_stripped_anat_segmentation_controls.m'); exit();" -logfile $subject_directory/log_batch_recalage
PID=$!
wait $PID

echo "---ETAPE 2/2 PARTIE 2....---"
source $script_bash/roblob_avcnn_etape_2_partie2_controls.sh #fabrication des fichier images de lobe de matiere grise et blanche dans l'espace natif, calcul des volumes dans l'espace natif
echo "---FIN ETAPE 2/2 PARTIE 2....---"


#lancement du script python pour mettre en forme les donnée dans un tableau
echo "---MISE EN FORME DES DONNEES...---"
#source activate Python2_env
chmod +x $script_python/data_volumes_manip_Roblob_AVCnn_controls_avant_correction.py #marquer le script python comme executable
python $script_python/data_volumes_manip_Roblob_AVCnn_controls_avant_correction.py #executer le script python
#source deactivate Python2_env
echo "---MISE EN FORME TERMINE---"


echo "---REORGANISATION DES DONNEES...---"
source $script_bash/reorganisation_fichier_roblob_controls.sh
echo "---REORGANISATION DES DONNEES TERMINEE---"

echo "---FIN DU PROGRAMME--"
echo $(date)

