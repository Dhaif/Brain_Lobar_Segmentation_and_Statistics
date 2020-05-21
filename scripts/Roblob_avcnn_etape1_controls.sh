#verification de l'existence des chemins d'acces des donnees principales
if [ -d $subject_directory ] 
then
    echo "Directory: "$subject_directory" exist" 
else
    echo "Error: path:  "$subject_directory" do not exist"
fi


# ---ETAPE 1 de l'algorithme RobLob: NORMALISATION DANS LE REFERENTIEL DU MNI---
i=0
compteur=$(($nb_subjects - 1))
while [ $i -le $compteur ]; do #tant qu'on n'a pas parcouru la liste des sujets


#creation du repertoire ou l'on veut sauver les fichiers
mkdir -p $subject_directory/${subject_list[$i]}/$save_directory_name


#copie du cerveau extrait de brainvisa du sujet en cours
cp $subject_directory/${subject_list[$i]}/$common_path/skull_stripped_${subject_list[$i]}.nii.gz $subject_directory/${subject_list[$i]}/$save_directory_name


#recalage affine du cerveau extrait par l'algorithme FLIRT issue de FSL version 5.0
brain_extracted=$subject_directory/${subject_list[$i]}/$common_path/skull_stripped_${subject_list[$i]}.nii.gz #fichier cerveau extrait

echo "Recalage du sujet: "${subject_list[$i]}" en cours..."

fsl5.0-flirt -ref $atlas_reference_recalage -in $brain_extracted -omat $subject_directory/${subject_list[$i]}/$save_directory_name/affine_matrix_${subject_list[$i]}.mat -out $subject_directory/${subject_list[$i]}/$save_directory_name/affine_registred_${subject_list[$i]}.nii.gz  | tee -a "$subject_directory/${subject_list[$i]}/${subject_list[$i]}.log"


echo "Recalage du sujet: "${subject_list[$i]}" fait."



#recalage non-lineaire du sujet sur le template du MNI avec l'algorithme FNIRT 



echo "Normalisation du sujet: "${subject_list[$i]}" en cours..."

matrice_affine_recalage=$subject_directory/${subject_list[$i]}/$save_directory_name/affine_matrix_${subject_list[$i]}.mat
subject_T1=$subject_directory/${subject_list[$i]}/t1mri/default_acquisition/${subject_list[$i]}.nii.gz

fsl5.0-fnirt --ref=$atlas_reference_normalisation --in=$subject_T1 --aff=$matrice_affine_recalage --iout=$subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_${subject_list[$i]}.nii.gz --cout=$subject_directory/${subject_list[$i]}/$save_directory_name/nativeToMNI_deformation_field_${subject_list[$i]}.nii.gz --jout=$subject_directory/${subject_list[$i]}/$save_directory_name/jacobian_field_${subject_list[$i]}.nii.gz --splineorder=2 --refmask=$brain_masque_reference -v | tee -a "$subject_directory/${subject_list[$i]}/${subject_list[$i]}.log"

echo "Normalisation du sujet: "${subject_list[$i]}" fait."


#calcul du champs de deformation inverse pour fnirt et flirt pour aller du MNI a l'espace natif.
nativeToMNI_deformation_field=$subject_directory/${subject_list[$i]}/$save_directory_name/nativeToMNI_deformation_field_${subject_list[$i]}.nii.gz

fsl5.0-invwarp -w $nativeToMNI_deformation_field -o $subject_directory/${subject_list[$i]}/$save_directory_name/MNIToNative_deformation_field_${subject_list[$i]}.nii.gz -r $subject_T1 | tee -a "$subject_directory/${subject_list[$i]}/${subject_list[$i]}.log"
fsl5.0-convert_xfm -omat $subject_directory/${subject_list[$i]}/$save_directory_name/inverse_affine_matrix_${subject_list[$i]}.mat -inverse $matrice_affine_recalage | tee -a "$subject_directory/${subject_list[$i]}/${subject_list[$i]}.log"

MNItoNative_deformation_field=$subject_directory/${subject_list[$i]}/$save_directory_name/MNIToNative_deformation_field_${subject_list[$i]}.nii.gz
inverse_affine_matrix=$subject_directory/${subject_list[$i]}/$save_directory_name/inverse_affine_matrix_${subject_list[$i]}.mat

#Application des champs inverse:

#---Pour le fichier anat:

w_mni_subject_T1=$subject_directory/${subject_list[$i]}/$save_directory_name/w_mni_${subject_list[$i]}.nii.gz

fsl5.0-applywarp -i $w_mni_subject_T1 -w $MNItoNative_deformation_field -o $subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_${subject_list[$i]}.nii.gz -r $subject_T1  | tee -a "$subject_directory/${subject_list[$i]}/${subject_list[$i]}.log" #aplication de l'inverse du champ de deformation non lineaire

mni_to_native_subjectsT1=$subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_${subject_list[$i]}.nii.gz


#----Pour l'atlas lobaire RobLob
fsl5.0-applywarp -i $atlas_lobaire -w $MNItoNative_deformation_field -o $subject_directory/${subject_list[$i]}/$save_directory_name/inversion_fnirt_atlas_lobaire_${subject_list[$i]}.nii.gz -r $subject_T1  | tee -a "$subject_directory/${subject_list[$i]}/${subject_list[$i]}.log" #aplication de l'inverse du champ de deformation non lineaire


inversion_fnirt_atlas_lobaire=$subject_directory/${subject_list[$i]}/$save_directory_name/mni_to_native_atlas_lobaire_${subject_list[$i]}.nii.gz

####----FIN DE L'ETAPE 1------#######

i=$(($i+1)) #on incremente i de 1 a chaque sujet traité.
done
