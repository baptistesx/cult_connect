import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../main.dart';
import '../../../login/domain/entities/user.dart';
import '../../../login/presentation/bloc/login_bloc.dart';
import '../../domain/usecases/add_module.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../../domain/usecases/get_modules.dart';
import '../../domain/usecases/remove_favourite_sensor_by_id.dart';
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
const String INVALID_ROUTER_IDS_MESSAGE = 'Invalid Router Ids';

class ModuleBloc extends Bloc<ModuleEvent, ModuleState> {
  final AddModule addModule;
  final GetModules getModules;
  final RemoveFavouriteSensorById removeFavouriteSensorById;
  final ModulesInputChecker inputChecker;
  final ConfigureWifi configureWifi;

  ModuleBloc({
    @required AddModule addModule,
    @required GetModules getModules,
    @required ConfigureWifi configuration,
    @required RemoveFavouriteSensorById removeFavouriteSensorById,
    @required ModulesInputChecker inputChecker,
  })  : assert(addModule != null),
        assert(getModules != null),
        assert(removeFavouriteSensorById != null),
        assert(inputChecker != null),
        assert(configuration != null),
        addModule = addModule,
        configureWifi = configuration,
        getModules = getModules,
        removeFavouriteSensorById = removeFavouriteSensorById,
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
          final failureOrUser = await addModule(AddModuleParams(
            publicId: addModuleParams.publicId,
            privateId: addModuleParams.privateId,
            name: addModuleParams.name,
            place: addModuleParams.place,
          ));
          yield* _eitherLoadedOrErrorState(failureOrUser);
        },
      );
    }
    if (event is LaunchRemoveFavouriteSensorById) {
      yield Loading();
      final failureOrUser = await removeFavouriteSensorById(event.sensorId);
      yield failureOrUser.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (user) {
          globalUser = user;
          return Loaded(modules: globalUser.modules);
        },
      );
    }
    if (event is LaunchWifiConfiguration) {
      yield Loading();
      final failureOrUser = await configureWifi(WifiParams(
        routerSsid: event.wifiParams.routerSsid,
        routerPassword: event.wifiParams.routerPassword,
      ));
      yield* _eitherLoadedOrErrorState(failureOrUser);
    }
    if (event is LaunchSendRouterIds2Module) {
      yield Loading();

      await event.characteristic.write(event.val2Send);

      var value = await event.characteristic.read();
      print(value);
      if (value[0] == "1".codeUnitAt(0)) {
        final failureOrUser = await addModule(event.addModuleParams);
        yield* _eitherLoadedOrErrorState(failureOrUser);
      } else {
        // yield Empty();
        yield Error(message: INVALID_ROUTER_IDS_MESSAGE);
      }
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
