import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../main.dart';
import '../../../login/domain/entities/user.dart';
import '../../../login/presentation/bloc/login_bloc.dart';
import '../../domain/usecases/add_module.dart';
import '../../domain/usecases/get_modules.dart';
import '../util/modules_input_checker.dart';
import 'bloc.dart';

const String EMPTY_PUBLIC_ID_FAILURE_MESSAGE =
    'Please fill in the public Id of the module';
const String EMPTY_PRIVATE_ID_FAILURE_MESSAGE =
    'Please fill in the private Id of the module';
const String INVALID_PUBLIC_ID_FAILURE_MESSAGE = 'Check the public Id format';
const String INVALID_PRIVATE_ID_FAILURE_MESSAGE = 'Check the private Id format';
const String INVALID_NAME_FAILURE_MESSAGE = 'Invalid Input - Bad name format.';
const String INVALID_PLACE_FAILURE_MESSAGE =
    'Invalid Input - Bad place name format.';

class ModuleBloc extends Bloc<ModuleEvent, ModuleState> {
  final AddModule addModule;
  final GetModules getModules;
  final ModulesInputChecker inputChecker;

  ModuleBloc({
    @required AddModule addModule,
    @required GetModules getModules,
    @required ModulesInputChecker inputChecker,
  })  : assert(addModule != null),
        assert(getModules != null),
        assert(inputChecker != null),
        addModule = addModule,
        getModules = getModules,
        inputChecker = inputChecker,
        super(null);

  ModuleState get initialState => Empty();

  @override
  Stream<ModuleState> mapEventToState(
    ModuleEvent event,
  ) async* {
    if (event is LaunchAddModule) {
      final inputEither = inputChecker.addModuleCheck(event.addModuleParams);

      yield* inputEither.fold(
        (failure) async* {
          yield* _streamFailure(failure);
        },
        (addModuleParams) async* {
          yield Loading();
          final failureOrModules = await addModule(AddModuleParams(
            token: addModuleParams.token,
            publicId: addModuleParams.publicId,
            privateId: addModuleParams.privateId,
            name: addModuleParams.name,
            place: addModuleParams.place,
          ));
          yield* _eitherLoadedOrErrorState(failureOrModules);
        },
      );
    }
  }

  Stream<ModuleState> _streamFailure(Failure failure) async* {
    yield Empty();
    yield Error(message: _mapFailureToMessage(failure));
  }

  Stream<ModuleState> _eitherLoadedOrErrorState(
    Either<Failure, User> either,
  ) async* {
    yield either.fold(
      (failure) => Error(message: _mapFailureToMessage(failure)),
      (user) {
        globalUser = user;
        print(globalUser);
        return Loaded(modules: globalUser.modules);
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case InvalidPublicIdFailure:
        return INVALID_PUBLIC_ID_FAILURE_MESSAGE;
      case InvalidPrivateIdFailure:
        return INVALID_PRIVATE_ID_FAILURE_MESSAGE;
      case InvalidNameFailure:
        return INVALID_NAME_FAILURE_MESSAGE;
      case InvalidPlaceFailure:
        return INVALID_PLACE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
