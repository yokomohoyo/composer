ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ���Y �=�r�Hv��d3A�IJ��&��;ckl� 	�����*Z"%^$Y���&�$!�hR��[�����7�y�w���^ċdI�̘�A"�O�έ�U���Pp��-���0�c��~[t? ��$�?��)D$!�H���x<��#�1	���_�eC�G�	��5o��_)t�ii�����8�BfWS���q x<an����aC�@��Ѷ��=�ڰAʚ�2u�6�>c)����m�$�g[�M�<ce��j&6�Ȱ�H����A%S��:(f�m�� �+�^��j����d����l�B��˛�$���吱�L4�!SVۚ�/���:X)&�i��A���I/�F*!6��(�&]`��&4���sQ��|2�M�'�a �&�vh⺦��lx����fjʢ��RL�c���8dYe���"
6���!�P���?��m�q(�34Y<���uka�Za�.sD�aSE&a��k<F}Z��Ӯ7̎�
y����;:�#؎Qa��S�g��P\���'jX��V���Ӵ΁���E��b�e8�����!�W`��㗖�Ȑ?gԟ?usd��{Z_}t�e��ǖ�Rf�t��4Q�0�M)F>�wn�P�Dl��_��(8�=l��]QQ:�g=Ѕ�L�C[2i�>x���\PQ7@�?��н�A�<�����(��_<F�EI$n ��{Of����X7
�׾��]�`����b8��?"�âD�?.�������B5�ՠ��,�
���@Q�?U3��$���re�C�ਜʼ�x�Ƀ���J>�>�g�0��K�0C��������/���
X���3��l�ๅ�{i���Is��İ�����������^g��;ㅠ����G3H� TX�l���`Α�c��պH�z(F�N�Ǥ;3�ݎ�u�M�f�bE&"�5�}�4�?�ih���?�Ȇ�<i:5���<��1֭ ��y�R:v��gN)���?]S�a��e"5M{gQ�0��H�Ѯ�kx�˚���҄��oaݡjю������V4vx��Н}k45G�� 4���e�|��; ����\�D�G�%���p)PJ���y+4.5����#8�Yx�Ib�ɰ�dQn�6���d]O��Cwu��a�tR��Q���0��qO ��@�1�a>���-M�4T`�6�"R����f4F/�,ίdٸ�|���Cq��s���X �q����-�&E�A~�x�EID ���Gڣ�!i�z;< ߇!°!�\�k���Q��i<<�8o=<��2���4k�#u���b֟@<>k�-��z���g�Easv8괇���-�[oQ�5������A�2?6v���<7�Ή�̲�G��q����  ��8z�M���z��蓘�Ohw������{�"�\��lV��]��c�n��rq��Jd�?����������y6�G�s�Gk�9cN�=`��xo��{s����M�#�7�f�e����l�^�N�oTi�O��=��&�W �L[�^��Z�ݩyu���C��#*�����_*̰���������bѸ�������ϗ3��������p|Z�����j���ңs�;s�����iW��c&�y�z�9�\'�1MJ�h��`�ϥ��OP'\u7_�PI��՝��nB^5����������ӫ1��3�%�,.������|��q�\�_\Fn���N  ��a!�%q�-�MpÆ��\�v��"��O�P�[�gO'��ҝ���V�r����/d���{=�6��b<�Y,�ڼ6���;b��M���Oo�@����,*�t�;��-x:��?��&��K˹]�E�C`8�2y����W�-"�K�d�@�'t��V�d��|�Sq�qY��f��Or����_!;wr^D�]������_������e���4��� .���(L��H|-������ɧz}O�NhY]�@�Du��8!�wг�k�sg�!�S����X&���ϱ�����?W �ן�p���^�Fp��+����]���������G"���_	L����]86�ܴl�L�/A���{!�nCC��݁P�Z{d�w],�~rL�������3���ϋO���|LD�V�����1���]�,���[6jdDz���"#��S��{U:���z9�}�L:s#d�E�߱w�:V�N��l�=1� `��������+�6�0��Sȣ3��b�E
V�x�L�_O�s���}�L�N��5�>��EG�X�\�����KP�2����"���������?���Tk�P�:^���.�,|tFT
}{�� 7����@=������A!(.�W୰dtoS���{�6��4��D���S��KP�2��J�)�G#k�_	����8�,���5�6�������O�	���f8~Tp~���M��./����Ʀ�_�G��+��������n�"۝Y���!w� � i�0���a6�� \�E��yT9�3CP���J�#L� ����Ѐ7�9���*D��� s�?�p�FO�E/n�.�x���)J��K6`�5��g�ز�$#^2/i���c:E�D�	&�,���%���ac*5����O'˘�c��X.�ɡN%�yz�{P�f�Y�?e^���<3|Dxn�6�df]]�hB��Bdx��g%�nl�W3�������<���5�'�q��1������[��H���)h_,k�.����B4>}��J��ϕ �_s���|����������k����?�HMP$)�ت+�"J	X��%e+���k���C$�H�I�Z"")PJD	�ߊ�k[���|���kn�������ɝ����8"��7�_Q���ۧ��M[s����O��Ђ�ʿ���6���$��ꛯFtx��=�ugm�����n��ɐ�O�oNL�y5��?l<&H����6��
�8?x�o��Ͻ�.�^���{�6n��#�Z��>q��t�7ic��__)&D��p�����ҭ���2�1�BJo���a��4�&~����M'K��+����-�6>v����aM@�X�.(񭈰U�J��"ն��� ��-
JD(n�a�&�!L@I��I�O�WQ�uj�p��\�R�r5�ͧ�j���3
�|*w�J�J�!��I��/�E��8.�諡d����5�i�^�q���g��s!Cp{�ef�P�[9Y<�$����q�"s)����1!UM���ZNo�"�x��Ȟ�G�3��>&ϴd���iX�<o]��W3�D��2㜽i6ko��Y%z^�i�8�j&\l�3��31{�M�X�*��y>\�慃j>|B��Y�0,{g��'k���K�N�ǥR.�{}|t�����ѥ���R8k����ҎvN���B����P|g��N>s�?=���7���e�^H
C��NJ'e�De2F��Q.k+�}�]�֪�32��B.���������R)�s/�+y9�s��.�%1׺�T�x�/��N�NΣv,M��\}��5�['�q�|T?�{�^�M��g�N/�U���VA=,�ΤL?���W����,�� �UӽL2�+�5�m�����r!)׷2�,R���Z�Ԟ�O��3�ē�d�a��[����N�H@�B*+h���]��NA����
�d�!2G�|)%Y{��;#�i|�UO��/ѓD�i�����QT1N�zǉnJ5�Jt/����}gq�3�^!w*�7ǅ�C(h����w��QY�yg0���3Ā�P0��>6���z 3������/�nnH�D1&����������o��_)|�������>�{�kX��/��G���DD1���[	��I���11`/s�Js�|n��dy��N��>T���|o?���PBk�b����X��oP1w��]=�F�ey�d��&q�R�\6�)�tT,w
G��,L�_\K픎_�P�1'����r���(zt��i�T��8�ة�Q*r(}���ӻU�Q��ą�cη|���g����/]��ѵ�_|6���>�����a�ó��:��J`��%��q�m�2��]��#%�����\Rҥ����ɦ�`5��pq�pB��^7:�y���Y��� �)��q���DcwĽ��֥m�mC>���ֻ��Q�ô���7��=�ܳ�ہO��~��4���5�}x�_	["�����Qi��q5��p�o���|�@��� �u�i�ʈ���(��������6����5dn�Q�[�G���F ���Fu��X��Ө.hh��@�mh��~�E-����}vi�?��e�8��5� ���~g� i܆����X�}�M)�R�*V���EPC:�$�jtd#0�`��zú2�1�]l��/y�s��<�F�={�P���y��N�>4�>�#���8Z��2��d�k�{u]�xͦ?v5�B42����>vL��k���U����-У{�`��H�"2}�F/]it)xtذ�@h h��O���_��!���0*�Ӷ-�v���=���UOޞLI ��裣���&�6���/lP�%��ay�^���Ȝa���Le@}���(����&��g���TDU�Oph�T��/����Kwu�I��3�����p��A�|s9y0��r����>��.�2���۬3t�>izIj%"B^�/���e�.���c�1m;��u�I��vE���̉�u�2��7���ql�8\\�o*@ [JY1X#83�T���ˇS.C	|8�B\;�݋�T "�66��JإH�C�-F�"���G�1�e x]Jt�[��Bn�����[K��'���C�;�1~��\�^���h�%�Y�͗��n���e�6Tt�W��M��7L_����U��l�Ql�>���5�N�`��u#�v�*C:14�t۱:!D�(�c)"�b86�԰���y*��dM[������;:��kh".�htB�
�*�ݞ��c�W��k�G:��ꄎ�m��\�Ӿ�~�Hd�v;d�|�1O�i0 ß_|0q:�Xn���Au�C�mPQ�3| ��*����X����wj��l�?=���b�� ���m,���RD�������޵�:�������"5��`�P�t��T���I.SR۱�87��y��rb'q�<n��I�X �h����;$f�����A,X �X���#�㾫rk�9��u�}������?q���%!�C�/��y�~�_J���_S�'ݟ+�������ⷿ��_��#����pd�����^��я V�mp���P�O?S�hHV$L
��Q���#M9�����&���V� 2*�A��h��C�/$�<
|�k��_�y�S?�~�+?����f����w�=�.�,�O�#o�P�z�o�|��] �����{�w�{�_��	�|���|���O;���߿yh7\h�@�)-V`��\7-Z:�RH�W6�>e:��n���
,�c� ]��^傫��!0-�pW(�FUq-���� �	n���H+	�g�4!��s�W �^C��-�g�"��y|I�mZ]���(����s昭W��� �h��P��	�Kq&.ZCw��t�9Ȏ[Dv&�fN�9c��5�*�z7���N��h����"�<۫����qP��N�6������4�`r漋fP�k��)����)�4�]�̎5]S:�K���q��t��DvV��͙�,�)+#ٕ�m!��,�f�Ӆ����w���B�Xښ��'&��Mք�E;s٤�lI�!���N����<�s�apS�>��H#M��Q����h������<��Qd�V�E������{S���` �XT#��j�LM�;�p\�[l}y��v�|����$%ͪ��Q���(=7)177��S~��Rhъ^BWg�[����䦻`/��B/��"/��/���.���.���.���.��b.��B.��".�]��K�yy�����[�'I���JF)�@�{j���D�czK��f�V��j�������P���%t�]T
���Ut��TO�LY @�p��L�N� ���u��<5b�d$=�"s���!C�4�b��[h�?�USD_nʄN�4��#�Z�p�,�ES�c��'Fcs$��u��A\�s�i���q���1	����lY��N�$��4�VD�)3�-�������c9�r����0�!͜ΔY31�W;1uA��t'�q��e"�ղ�>�p��iE�ʍrn��#2�f�v�ݎfQj�]�eޅ-Ի����/�� px�������no9֟W [��~	����Jx7�>Cދ۷��`�om�#Mm-��9�Z�����P'�|�A��.z���qGV_��x���E���-|���������7��c>�������{�ŕ�,��D�,�t>oDg9QW�<S]d�H�F��֖Η���,]ru~�������˙$`y(���X͂�<]Ʌ��j�K.�]��8��46%pM`ʮ���P`�TEZd:-GY��Jqc<f!��T�Y�TdJũ�1;�+�^�Q�puv*�x67��f=u��|C=��(:>h*-}�4�y#L��vuY$���+#<j"5���R&
u<T�RݕH���&өs�w���~{�i LS��� �������-*C��.�����q$bH�ѹ%����(��U�����)��(;��2��jMY��d�����c�R�����eAt0���A�l���͜6�����.3T�aM9n̆�*�K��/h%t��#��e���ߺ�i��Pnz�r��Fy�<(�L��frzg�-.������������lȉ%]qdv�����	�X�	l}��q�,�_d��������3���2.�#��w��h����=��K��UmZH^O�#�-�2Z�dCW���1�HZ>�'�I]�f+�0��l=�W�By�T��>F�bF1fqЈ�������aT���h#KS��y6+p���mچ2g�q���S�YzL�`�#�S�r�)��|'���:Z{z�v�O�=��� S>�+�x2-l��Ua��wiA���jѼ�lT�t����K�"�4ڼ9�������0VG��d�O�<�ۭ��4�R�����b�@���e�ٍl⿺�'�"P$��"��Aa<�����ǘ�ܕBUb6��*����E2O������FH�P� �=�q�	���/U&��s�I��BA�{ޫJ)=ʕ�i||�SZ)�!y�T��؄Kb�1��v�����!��8�%����Y�d����ryT�&C�2:��Htٝ �r[���e�B��3u�<t�·KSR�>4��M��B�[��Ka!%nH^O�0D7����	��Bs>�I�R�"]���yz6@�A*��tl�0��J�Y�ױ�4h�C͍�kp(�b�Ѫ�J9V�q�1�g��Vv��eـ�|v黁w���W�����	�L�k�l�_B:�hQэ�j��2��4W�S]\�����[ț�HyY#?�HF�[R�J���Gȃ�ϟ�>��|y�mGI�wo"o+��"_g�7������C�.^ ��M�J��<}�<HI:YKk��UQw L{���8� ?��J��(�O��	������׽�<��YZ�'��+z�<B>t�O�O�Уׅ{�{��#�5��C�K���?�'2�׃��t��?�
m������}�������`����z���I�U�m��\C��^�t�h*Az���]+3�o=�t�����X�Hŀ�bGn�qH�@�Fh�E���~�/z~���?��_��.nw� ��|�$���Q�Z��]�^6����i�����u������*�h�k�rzU�*�dG'Nv��e��15������/��K6$�d���~$�(r�����Òt� 䣍�"X�E�jY� =�]�}��1�..��;ol�0hY���`]��8�N�A����T��C��Y`P ��ԧB�|5��+ ����Zb�FV�&�'��w��GA�~��=�/�3� "+hљ^�|�l���ֺO;Ի�ƫg�d4�{e����s��x�.��
f��VTϳ^V&֟�:q��P4��?ƒ�u��8�ֽF�hǫ̮�$�viy=_�6с>�w�2`:�X`j����x�[	`�'갥�%�$XY5
��pEd����\N _n���3r�ď��Y�D�^�A]ןw�i��&��������jm��]�
]���g	?ϯj�H&#]���;�/�����o���t��=���ި�5�w oAxs��'�s(sc�6A|G�m�7N~���'���8\\�s��5�+u��3�`@!�6[r8?h��C]���&���	��ֹ�5Q4�l]\/G�ؖ�'�=��(
�q.�0N�� �� .���e�b�g��ٗ1��6�18�x1���R�/ٰS�	���n��r�8�I𢍷�]x�t�1��J��B�z�iJ*�p���m�B�`�����BN���^;8Hv��o��V�a�(X�Hp�W��:�4�4
vY?fv ���t���ڱ2XC�Y_�p��Nm.�F7�y�Z�4�,k���r�o�������i��"�ze�J�5,y��UǞ�D�ӄղ�p,����[6�7�^���i��e�M�[o�R��w[��h�����ZL�o���n��V��v5!$NO�9|r�k����@=X�T�5�l�/ �C`���qe��*��D�ࡃ|�F���u��mkCL�D�)�İ����y�i�vq�/��������4T�ܻ����886�P1�Ѥ�ȍuK���5��c�Q�Oq�G�w���w�_�b��z����ύ���C�\��������E����>Xq���  �e[%;bnزS;�F@4�ٷ�YݳN�L�����3��-tguM�(X��~��V;:�|tY)��,�g���j׺^��p��X���S�~�v$���v����$5�H�P$2���6E�[-��ˑ6.ID3d�#�f�َQR8U$�����-Ȁ��]n"��aV�3'��e�v�OZ�O6�c[��'֓�`�0fȵG�cA�	���+��U�Ǥ&EJ�fG��,�8��[��$���1%�E����2!!����ƔpD�%JR��	>i��N�ϱ|"gcf�m�7]O��[zr��8K��';�����b+�}���;2^���b^ȶ�"�-�NrY�Hg�2�d��p�g�Ҝv.�ƗD.K�l�+��aк�.��-�%�S9�<�"�n�rO�/��vɠ�tF(�y���x�� ��V��=��*�
��ٙNg���@;#p����Q��	ii{�֙�uP�������7� l����ԝ��l7<�s�D�;�L�v��3d����d7�_r�r1�oE�����"�<�g�gy�+n:|O�|6�cW9m�`9��\�Zθ,���Y��t��OP��љ4A'ӡc[=���	K���,����ȟ��f-m����O���\I��	>y���j�x*X�{�љ���z�k�cHng��ڵ�i1��3�����c�VْH�����E��Kܳ8y�2������8cr�r'ȍ�JƢ�ʠ��O��'O�كw&��%MW.`a|}�@�1t�"����d�������|�l�Ml�9c�o�.�c�[��W�vY+CY?[}�y��sH#�:vkk'���fWH�+�oE�;�˜������y�:P�Q���Ͷ�w��v�80`�w��/a���#�q��ytG7^��e����Gz��%�o��!"�����M��������}��������ۄ=�=�}��-�?:����WA�8�)��H� ����%��ϋ?	��4|eӾ��%�qr��/����{I444/��}���+a��;�쿽�}����]`[��X;�qKv�qLn�CdK��V,�[
Ţ�P+DFB�H8�41Y�Ä�:�_u~�ӫ��Q���w������6�d�8���>��CC��2:M�#��}������t��뺒�Wf��F�T���S�"���6����a9�Ck ��"Z���^oKE�I���Տ�NJ�zoҩ']-����2�I�0��{q�ϟ,���ӫ������^����!�=�Cڝ����9�ǩ���>ҫ �	l��� ����%�/������ �����������>�=��Ծ�)�J���?��{��xd���`��%��^�@��)���A������ږ��A��#�Z�����_ڗ���&�-�O������:�:�:�!���޵u'�n�w~�~w����a�q����x�e@D�������I��v'�� ]Y�)e��Rt2�\k��P��=�����RP�xP�W�������Sw���%�F�����?�����[
ު��k����J�7gY��_u�vHe'��?�J�?]Hn���u������c���?��y]�D>������ɬ"�>��y[�D�&��Ab�ˬ�Z�,������mf�K�s{;I3+��\u�t���=��u�Ѡ�X�ȼh����m�c�����{{������ާ��W[&��6��6���k��P�<!飩��sw�Y����۽O�[4W�b/L<9��ȉcWTш��kD))f�@�Z���2^E{Ǒ����a�c��v�_�45m1g:;̬��f�B�A��2�@�=-��P����������P/�����Q���A������'����j����Wj���8���� ����������_���/�������'��?��W�7���K�����n�ɞ�Ѹ����O;����[ٯ��?��/e}g]���y���﷝�i�?��*��J�����֪���bm�Kth�M�|�h��쪂�Xp�ٶG��M������l�a�r�T�#��C^��^~�	u�ϵ�~!�f�&�_��ȭ���6�u��S����G4�c�㢳��M(%�f2_�f'�`4UP����}"��p暤 ��]n�Psd�MUN<����ژ�����+j�����Wj����9�'���
 ����u���{�)�����N�?���(l�46�X�'Y
�8�ѐ�Y�	6��h&�	?@��(�#|4DጀG��Q�?����W��gE���XH��VӠ�,����N���1o/Z�x�����o����������Ðr9Ys�bz��TA&�[�O}�l��zC�~�c�(��X��n��d�͈���a38�޴���E����Y*���W���u��C�Wj��0�Sj��Ͽ��KX���Q����:����`��}���q3���B�`F�)G;��N6�]�f��V��]���C1�7c�3���R��xDќ#�܊Q<�$���A��1����8�r�=;4lk���<�#S�Q�lھKA��^������[jp��?������P��/������_���_�������Xj���N�8�2��s�����������+"���$L����.���$��৷���f�!�5��3 ��� ��z�� �(�U��*U�z��g ��q��G㛍�>!�"��Kt��fH��j
Z'W���²��"ވ����hc^�6��x��O9�^ԛ�[p�~�^Dn�#�k>�w���)\s����x=�tZB��z`'DrK��O�_�������f�CC9�g�b��B�F"�e�q��z�A:Z�����i�u�!�6�����K���0~����^�MQ����i��N�"����x2���I��v;$�l����fh%=�,4�گ�M��[}���I0��輴;�v��{Ѡ�#�?�_������G}Q�������P�e�����?��_
J����-�������������������_m������q�OS���(ɢ�ԛbxH��y�G�$2(K�!����i��S�I&�<�a���P�����/
��R�+�ݞXj�P��ܵq��}|8�œd����ɂ6t21��e��H�8���ٲ
r�'Uq�ö�� ٬	����|7<7{��yH��C�W�уC[w��v"G�-{�C�u�ߋ:��1���?�������k�C���w(�����	��2P������+	��7]ǐ�^G ��W������t��_���k����G��	��2�f������翍Co34�iSP�ɘ�y�2�濃���o��n��2n̑����>�����������w����`�(�q�Zp�7g����S�'�ևI���x��Ԟ���h`w��������M<��Z�ԊcJg\�Ms�5,F��i@��|V�\[ض��yRA��\�9��zmۑ�qna�s�#����e�����
���v�آ��Pm���S��ˎ��"�i&��r���IH�^�Q#�9߸FR��ڌ�|��i3R#���dmt�Ӥ�ȩ'���1�v�C�Hr�qj8��c٥������ߊP������
�����������\��A�����o����R ��0���0��������,�Z��������������ӗ�������$��e �!��!�������o�_����!��Ъ�'�1ʸ���I��KA�G���� �/e����-T��������
�?�CT�����{����Ԁ�!�B ��W��ԃ�_`��ԋ�!�l���?��@B�C)��������O����a��$�@��fH����k�Z�?u7��_j���R�P�?� !��@��?@��?@��_E��!*��_[�Ղ���_���Q6jQ�?� !��@��?@��?T[�?���X
j���8���� ����������_��/���/u��a��:��?���������)�B�a����@�-�s�Ov!�� ��������ī���P���v�>2�?C�%Pv�r�, }6�H�/$A�S<�e<����<����e���}Q�'h������?P��
�?�<���J�Rq��T�

�{Wo�4#U�nWВ���K�F�?D-l�h�:�ZR������7D��bf:� ՝e��D�Qɵ�J~!�p��u�Z��r�m\�#q>�8Ir�{x�{ߔ�ù+�m4\��>Ot�{iw���~�k�:��!��:T|�߯��[)�p����:Ԃ�a��2Ԁ����2������_u���_? t�������h)�otg��^���@����?��|*o�����{�`���I�6����i�:H�l<G�zj��SK�6��A�w��Oғ�o�[]��<m�9Jh�A�n��LP�����ߝ��oI���?��v��k�o@�`��:����������Z�4`����|�����>o��S���M�	�dH�#qGo���-����o��Zٯ����*�$�\K��c��'�H��n��A�!�ܖ&��$�#����T�Xmg�``iGL�F#d�H���|Q����w#:%rг=#ӕ$G��(zy��O�N����NK�u��^�	��.�;~��ț�=����(ꇆr
��b�~�	�b�,��a�2�t��~Y �u��6s�-'��3���O��T�{��Y��'wf\C�.]��u0�؆�z��M��jߘr<�Di{L5�ÖX6g��b���]����d7w�o�Ǐ�Q��o)�����������p��@�?�|��	�ߥ�?�O�n0�U[�q���Ic���@�G���/	�_����\O��������`^�$�S������?�E~z����ǵ�n�1s�1N�N���u�r_���-��n�"��Y��ʳ�&]~ԭW�B>z�O���s?n����3s9z�����֥��ͺ\�˫syM-A�[2�y[���U���� �ׁ:��!Lghb���՗�>��Fk���
�Le1�g#�=���F�\4��V<gM�&%컘A�'�bU��c���|�`l>���s��}���7ork�.�5��|�������C��پ<d�������J���8݉�%����b�l��Q��l�Tc�@�!K����+�92ڼ$�|,��nl����O��G�k��1w���5B�p*����;MOȭ�=xk?���7ԕ��:ۮ�8�'�z�����P�G���A��$����B}#<����{܌0��0I�%q�g��!	n��OT��>�y!`S���,ԡ������?��+�r�_���v���+Edw�����[��ɧ��:��sW_����ʟ�
��rU+0��^|���j�~��Ca$�e��c�{��_)(���_�Q��������h���-��[\�?�����c��b�/�Ά���t���]��䭗�:9�������|��[~�C~���Z�;���.87�w��n��>��$��6�k��-ҝ������D8�O��ڔ[cFo����݈�hߍ�y@����,U���%������Չb5����Q��f�!|?ϗ�u,��(杙����{J����t�&-+��xu�,xy����8</�c��칳^1����.%J�R~���K'��Su��J�̔fXs.l�9�
�q����T}e5wg��/��:�?����������Gd�,��Č��k�/�/_QL�|��0��X��7�ELY��=�.�`,G����(�����G<}�A�}>~���j��T�B�Ey�S�FN�<	WZ�D�*�@��-�����{�rU-�Ge���g��������A�]�޽�CA���2>��u�Nx�%���������%��s��j�����?�]���P�����?�5���v��9�4U�Y���ە�n/���}�C���]Po����>�
~x;�QZ�[��A$�cɖ	]����|6���X%����Ǥo��Åܽu�����n�+����?y���������IMl���WpsR��-O7y詓[��ﷷn� �Pԩ��/��I':��L�����J�na߽��k�����]W~]	/�e���Z<-�Q�k�hok��C����`��*]�훭��;ݡo�O�U���ރ���fV�XN�v����i�"f-��O��V�^)�e
M!>��X=��(5!n��}��ԍO�ǛC���n�Q�Z����֮��ۆ-)M��hq�UF�$�͋R]�䀽���ڮaLJS��L�>^�s�������EK�7�v֬���@p�2`Jr]�VR�Q��`�1����Z�$E���z%��3�o����������?��E�oh�����o��˃���O��R�!4������䋐��	�	��	�0���[���9�0�K���m�/�����X��\�ȅ�Q�-�������ߠ�����`��E�^��U�E�����	�6�B�����P�3#������r�?�?z���㿙�J��qA���������������2��C]����#����/��D��."�������P�!������K.�?���/�dJ��B���m�����E���Ȉ<�?d��#��E��D���C&@��� ����������u!���m�����GFN��B "��E��D�a�?�����P������0��	(��б!�1��߶���g�����Lȇ�C�?*r��C�?2 ���!��vɅ�Gr0������<��������۶���E�����2"�op4E��^��f����U�Mư��U,��ɗL�`8ò���la�,�|�#9�c�V��OO���]����/��NO%nިN���.�U�)6e��M���.K���Ze2�ұ�n�����N�"Yяi����m�A�e�B;b��ўl7�EOH��M�j�h��N�� n�����ڡ�P�̹֒ʐ{��i��_�zs��صj�Q�(�������`�$�4ڃ�����߻�(��3���C�Ot����5���<�����#��?�@����O�@ԭp��A���CǏ��D�n�����cb"�X�7
q�0�qܲ���-񻨶������ר�V�y�=Xmt#�z䶶�P������G8گ���~��[��Al�p�jb�]#y5�.ձ����ăj�BO����/��/"P���vo?c����E��!� �� ����C4�6 Bra��܅��� �/�Y����k���-;
j~h{Z�*��*�y����j�n�}>ŊXg2��+�+;P�}=؆�mHE�^o�eI�m�g�q��������mݝ��Hƅ��[>$�9v*x~91ɼ�d�i�Z��6���/j]mW)��C�a���^�M�9[g�p����a^E�?�r�a��5فhWkbר<�)�SQ����^m��9�@��/��onVՊ�د��^�|��OIl���TJ8�Z�6p)�+���*��.��T�B�p�i)�J�R+aBr]|��7KC�h�]�8.n2���M�~z��%y��(�?����� �#�d��k����A!�#r�����/�?2���/k�A������O��?˳��Y�T��$0�p����#��J���dr��8궸E@�A���?s%��3!O�U �'+��������o����P��vɅ�G]��/���$R���m�/��? #7��?"!�?w��KA�G&|3���h��?���oBG��c���&��2.�?�A��F\�>���c�G�X������c�G�a؟��HS?�W��N���9������<���.�[t�~�+��Z��q�*~Ǭ-�X��0�}c^�P���T�i��l���i,N�6�i��G�#�%k|�lj��(�:J�~�?������]�����i�a;�ВҨ��&{[A��ʴ��cA��NB���+8��Ld�,��͈"�gV��$mm�Չn�Yck$Gm���O�݊E�5��,����XY�a(�u��
�X�΀A.�?��Gr���"��������\�?��##O���F2%����_��g����_P�������Ar���"ਛ�&�����\�?K��#"G�e xkr��C�?2���W*i������v�5�H8�\�-{М���������X���'Z{c�[���9M��r ��_>� ���V���64z�()� 8�S�Y�o���6mћ���fH`J��JT�O�ޢY-ڨ�E.no���,+�È�� ,M�39 X��{9 �X�{�b��¢\��.��J��/L�sUl��G!]X����m�ɲޕ�˛����ȤV�kJgi�8�M��
�5���X_�?���Ʌ�G]Y��er���"�[�6�����<���R����������V�-���\��y��i�%u��)��h�,�M�2,R�I�bS�9�\��9�}�����Ƀ�_[�����G��9�g|�aܒ�0���	��i@�4j9���ɬ�V�U͜F�������ћ�Dco?ЪAl�����z��+V��]Դ�~?W�Sɡ�Ӱ�F�A����:1�'U�
.q��rٍ&���k�C��?с��O�B� 7N���Б���d ���E 7uS�$y�����#�?�[�˚ޑU���X�X1�x)��~�!������؉��g���KGv;li��+L�a�2kB���Ƙ���د��	Y�z��c�=����Q[����Y{����К\��������by��,@��, ��\�A�2 �� ��`��?��?`�!����Cķ�qj���g��aa����w,�.��q4ܒ�EH�_��{��������x�PX��N[W�h�i݂��~A���?�w�n�5sTnQ��T�VD�X�J|t��$,6ŶZ(��=4?T�:U�Z۶�^J�������v��	q��d牏ת4�(v�u!N�CY�kbܔ����%��D'�O�Æ_*�n4��RU�t�@�-���c�]E$cL=��'J�Yx� �iV���6�KCz��?m[~���
�4�zu�y=�n�|ِ��|r�S�p\۳c�X^������H�1X�F9zXp{j��6F�����ݝ�L�*N��_�`�n�_xq��;g=���볿��$��_�?ͤ���g��;�MO������S���������mE=�^�5A�)�G�&������q;������g9k�����T���	���v���ĵg���O�ם}�~��~���Bs]s�|()0������������?�V*��槿��}c^���OIT{�r.��3�1�Gq�W�4ͧ����=�/Bw\B�������\�r�0�� ���~��������yx��f�ߙ��=32�ds�9�]`bBO�����6��l��Y4�&n��L�7w�do/8b�������O$����/�Я췇=���������w������<y�{|�/�~}��i���>��'*�
�y~g]�O|���q�N��?�0;���WkI�Z^�׏��͹m��q�#|����В�{ֹ�C<^$��\�qm|��[��;�'���Ŀ��@�>�f�=|��Z�Orw��3������ھ�b��4��ܚ��Y`�_�d��99��}��{/���N�㟟�Ǎ�!�<��x��x�%��Z���&�� ��x���|z��縿uJI�����/��.��v���S��>6��ݪ)�c'wqi�.LE�v�ן����U�LO�N��ҟ���>��'��o��                           .�ۤcX � 