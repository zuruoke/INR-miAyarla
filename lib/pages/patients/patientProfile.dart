import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:health_bag/functions/general/formatDateTime.dart';
import 'package:health_bag/globals/myColors.dart';
import 'package:health_bag/globals/myFonts.dart';
import 'package:health_bag/globals/mySpaces.dart';
import 'package:health_bag/pages/patients/patientEditProfile.dart';
import 'package:health_bag/stores/login_store.dart';
import 'package:health_bag/widgets/backgrounds/fourthBackground.dart';
import 'package:provider/provider.dart';

class PatientProfile extends StatefulWidget {
  static String id = 'patient-profile';

  @override
  _PatientProfileState createState() => _PatientProfileState();
}

Widget _getRow(String key, String val) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyFonts().heading2(key, MyColors.blueLighter),
          MySpaces.hLargeGapInBetween,
          Flexible(
              // child: MyFonts().heading2(val, MyColors.gray),
              child: Text(
            val,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'poppins-semi',
              fontSize: 15,
              color: MyColors.gray,
            ),
          )),
        ],
      ),
      Divider(),
    ],
  );
}

Widget _logoutPopup(BuildContext context, LoginStore loginStore) {
  return new AlertDialog(
    title:
        MyFonts().heading1('Are you sure you want to logout?', MyColors.black),
    actions: <Widget>[
      FlatButton(
        onPressed: () {
          loginStore.signOut(context);
        },
        child: MyFonts().heading2('Logout', MyColors.blueLighter),
      ),
    ],
  );
}

class _PatientProfileState extends State<PatientProfile> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LoginStore>(
      builder: (_, loginStore, __) {
        var uid = loginStore.firebaseUser.uid;
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                FourthBackground(),
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: 20,
                    right: 20,
                  ),
                  child: MyFonts().title1('Your Profile', MyColors.white),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15,
                    left: 20,
                    right: 20,
                  ),
                  child: SingleChildScrollView(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Patients')
                          .doc(uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          // Store all the user data obtained from FireStore inside this map.
                          var userProfileData = snapshot.data.data();
                          userProfileData.forEach((k, v) {
                            if (v == '')
                              userProfileData[k] = 'No data available';
                          });

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyFonts().heading1('Personal', MyColors.black),
                              MySpaces.vGapInBetween,
                              Center(
                                child: CircleAvatar(
                                  backgroundImage: (userProfileData['Photo'] ==
                                          null)
                                      ? AssetImage('assets/icons/patient.png')
                                      : NetworkImage(userProfileData['Photo']),
                                  radius: 100,
                                ),
                              ),
                              MySpaces.vGapInBetween,
                              _getRow('Name', userProfileData['Name']),
                              _getRow('DOB',
                                  formatDateTime(userProfileData['DOB'])),
                              _getRow('Age', userProfileData['Age']),
                              _getRow('Gender', userProfileData['Gender']),
                              _getRow('Phone Number',
                                  userProfileData['PhoneNumber']),
                              _getRow('Email Address',
                                  userProfileData['EmailAddress']),
                              _getRow('Residential Address',
                                  userProfileData['Address']),
                              Visibility(
                                visible: false,
                                child: _getRow('Sign-up Date',
                                    formatDateTime(userProfileData['SignUpDate'])),
                              ),
                              MySpaces.vSmallGapInBetween,
                              MyFonts()
                                  .heading1('Medical History', MyColors.black),
                              MySpaces.vGapInBetween,
                              _getRow('Illness', userProfileData['Illness']),
                              _getRow(
                                  'Allergies', userProfileData['Allergies']),
                              _getRow('Genetic Diseases',
                                  userProfileData['GeneticDiseases']),
                              MySpaces.vLargeGapInBetween,
                              RaisedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PatientEditProfile(userProfileData),
                                      ));
                                },
                                padding: EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      EvaIcons.edit,
                                      color: MyColors.white,
                                    ),
                                    MySpaces.hGapInBetween,
                                    MyFonts().heading2(
                                        'Edit Profile', MyColors.white),
                                  ],
                                ),
                                color: MyColors.blueLighter,
                              ),
                              MySpaces.vGapInBetween,
                              RaisedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        _logoutPopup(context, loginStore),
                                  );
                                },
                                padding: EdgeInsets.all(15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      EvaIcons.logOut,
                                      color: MyColors.white,
                                    ),
                                    MySpaces.hGapInBetween,
                                    MyFonts()
                                        .heading2('Log Out', MyColors.white),
                                  ],
                                ),
                                color: MyColors.redLighter,
                              ),
                              MySpaces.vSmallGapInBetween,
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
