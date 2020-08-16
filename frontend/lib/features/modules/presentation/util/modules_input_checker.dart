import 'package:dartz/dartz.dart';

import '../../../../core/error/exception.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/presentation/util/input_checker.dart';
import '../../domain/usecases/add_module.dart';

class ModulesInputChecker extends InputChecker {
  Either<Failure, AddModuleParams> addModuleCheck(
      AddModuleParams addModuleParams) {
    try {
      publicIdChecked(addModuleParams.publicId);
      privateIdChecked(addModuleParams.privateId);
      //TODO: add conditions on module name and place?
      // nameChecked(addModuleParams.name);
      // placeChecked(addModuleParams.place);
      return Right(addModuleParams);
    } on InvalidPublicIdException {
      return left(InvalidPublicIdFailure());
    } on InvalidPrivateIdException {
      return left(InvalidPrivateIdFailure());
    }
  }

  String publicIdChecked(String publicId) {
    if (publicId == null) {
      throw InvalidPublicIdException();
    }
    if (publicId.length != 3) {
    } else {
      return publicId;
    }
  }

  String privateIdChecked(String privateId) {
    if (privateId == null) {
      throw InvalidPrivateIdException();
    }
    if (privateId.length != 3) {
      throw InvalidPrivateIdException();
    } else {
      return privateId;
    }
  }

  String nameChecked(String name) {
    if (name == null) {
      throw InvalidNameException();
    }
    if (name.length < 4) {
      throw InvalidNameException();
    } else {
      return name;
    }
  }

  String placeChecked(String place) {
    if (place == null) {
      throw InvalidPlaceException();
    }
    if (place.length < 4) {
      throw InvalidPlaceException();
    } else {
      return place;
    }
  }
}
