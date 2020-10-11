import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../main.dart';
import '../../../login/domain/entities/user.dart';
import '../../../login/presentation/bloc/login_bloc.dart';
import '../../domain/usecases/add_favourite_sensor_by_id.dart';
import '../../domain/usecases/add_module.dart';
import '../../domain/usecases/configure_wifi.dart';
import '../../domain/usecases/get_modules.dart';
import '../../domain/usecases/remove_favourite_sensor_by_id.dart';
import '../../domain/usecases/update_module_settings.dart';
import '../../domain/usecases/update_sensor_settings.dart';
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
const String INVALID_PRIVATE_ID_MESSAGE = 'The private Id doesn\'t match';
const String NO_MODULE_REGISTERED ='You don\'t have any modules registered.';
class ModuleBloc extends Bloc<ModuleEvent, ModuleState> {
  final AddModule addModule;
  final GetModules getModules;
  final RemoveFavouriteSensorById removeFavouriteSensorById;
  final AddFavouriteSensorById addFavouriteSensorById;
  final ModulesInputChecker inputChecker;
  final ConfigureWifi configureWifi;
  final UpdateSensorSettings updateSensorSettings;
  final UpdateModuleSettings updateModuleSettings;

  ModuleBloc({
    @required AddModule addModule,
    @required GetModules getModules,
    @required ConfigureWifi configuration,
    @required RemoveFavouriteSensorById removeFavouriteSensorById,
    @required AddFavouriteSensorById addFavouriteSensorById,
    @required ModulesInputChecker inputChecker,
    @required UpdateSensorSettings updateSensorSettings,
    @required UpdateModuleSettings updateModuleSettings,
  })  : assert(addModule != null),
        assert(getModules != null),
        assert(removeFavouriteSensorById != null),
        assert(addFavouriteSensorById != null),
        assert(inputChecker != null),
        assert(configuration != null),
        assert(updateSensorSettings != null),
        assert(updateModuleSettings != null),
        addModule = addModule,
        configureWifi = configuration,
        getModules = getModules,
        removeFavouriteSensorById = removeFavouriteSensorById,
        addFavouriteSensorById = addFavouriteSensorById,
        inputChecker = inputChecker,
        updateSensorSettings = updateSensorSettings,
        updateModuleSettings = updateModuleSettings,
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
            routerSsid: addModuleParams.routerSsid,
            routerPassword: addModuleParams.routerPassword,
          ));
          yield* _eitherLoadedOrErrorState(failureOrUser);
        },
      );
    } else if (event is LaunchRemoveFavouriteSensorById) {
      yield Loading();
      final failureOrUser = await removeFavouriteSensorById(event.sensorId);
      yield failureOrUser.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (user) {
          globalUser = user;
          return Loaded(modules: globalUser.modules);
        },
      );
    } else if (event is LaunchAddFavouriteSensorById) {
      yield Loading();
      final failureOrUser = await addFavouriteSensorById(event.sensorId);
      yield failureOrUser.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (user) {
          globalUser = user;
          return Loaded(modules: globalUser.modules);
        },
      );
    } else if (event is LaunchWifiConfiguration) {
      yield Loading();
      final failureOrUser = await configureWifi(WifiParams(
        routerSsid: event.wifiParams.routerSsid,
        routerPassword: event.wifiParams.routerPassword,
      ));
      yield* _eitherLoadedOrErrorState(failureOrUser);
    } else if (event is LaunchSendRouterIds2Module) {
      yield Loading();

      await event.characteristic.write(event.val2Send);

      var value = await event.characteristic.read();
      if (value[0] == "1".codeUnitAt(0)) {
        final failureOrUser = await addModule(event.addModuleParams);
        yield* _eitherLoadedOrErrorState(failureOrUser);
      } else if (value[0] == "0".codeUnitAt(0)) {
        // yield Empty();
        yield Error(message: INVALID_ROUTER_IDS_MESSAGE);
      } else {
        yield Error(message: INVALID_PRIVATE_ID_MESSAGE);
      }
    } else if (event is LaunchUpdateList) {
      yield Empty();
      yield Loaded(modules: globalUser.modules);
      // yield Loaded(modules: globalUser.modules);
    } else if (event is LaunchShowSensorSettings) {
      yield Loading();
      yield Empty(); //SensorDetailsDisplayed(showSettings: event.showSettings);
    } else if (event is LaunchShowModuleSettings) {
      yield Loading();
      yield Empty(); //SensorDetailsDisplayed(showSettings: event.showSettings);
    } else if (event is LaunchUpdateSensorSettings) {
      yield Loading();
      final failureOrUser =
          await updateSensorSettings(event.updateSensorParams);
      yield* _eitherLoadedOrErrorState(failureOrUser);
      yield Loaded(modules: globalUser.modules);
    } else if (event is LaunchUpdateModuleSettings) {
      yield LoadingWhileUpdatingModule();
      final failureOrUser =
          await updateModuleSettings(event.updateModuleParams);
      yield* _eitherLoadedOrErrorState(failureOrUser);
      // yield Loaded(modules: globalUser.modules);
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
        // print(globalUser);
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
