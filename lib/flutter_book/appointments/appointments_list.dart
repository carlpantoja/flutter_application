import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointments_db_worker.dart';
import 'appointments_model.dart' show Appointment, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {
  const AppointmentsList({super.key});

  void _showAppointments(DateTime inDate, BuildContext inContext) async {
    showModalBottomSheet(
      context: inContext,
      builder: (BuildContext inContext) {
        return ScopedModel<AppointmentsModel>(
          model: appointmentsModel,
          child: ScopedModelDescendant<AppointmentsModel>(
            builder: (BuildContext inContext, Widget? inChild, AppointmentsModel inModel) {
              return Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(10),
                  child: GestureDetector(
                    child: Column(
                      children: [
                        Text(DateFormat("dd/MM/yyyy", "pt_BR").format(inDate.toLocal()), textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 24)),

                        Divider(),

                        Expanded(
                          child: ListView.builder(
                            itemCount: appointmentsModel.entityList.length,
                            itemBuilder: (BuildContext inBuildContext, int inIndex) {
                              Appointment appointment = appointmentsModel.entityList[inIndex];

                              if(appointment.apptDate != "${inDate.year}, ${inDate.month}, ${inDate.day}") return Container(height: 0);

                              String apptTime = "";

                              if(appointment.apptTime != null) {
                                List timeParts = appointment.apptTime!.split(",");
                                TimeOfDay at = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

                                apptTime = "(${at.format(inContext)})";
                              }

                              return Slidable(
                                startActionPane: ActionPane(
                                  motion: ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      label: "Apagar",
                                      icon: Icons.delete,
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      onPressed: (context) => _deleteAppointment(inBuildContext, appointment)
                                    )
                                  ]
                                ),

                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  color: Colors.grey.shade300,
                                  child: ListTile(
                                    title: Text("${appointment.title}$apptTime"),
                                    subtitle: appointment.description == null ? null : Text("${appointment.description}"),
                                    onTap: () async {_editAppointment(inContext, appointment);}
                                  )
                                )
                              );
                            }
                          )
                        )
                      ]
                    )
                  )
                )
              );
            }
          )
        );
      }
    );
  }

  void _editAppointment(BuildContext inContext, Appointment inAppointment) async {
    appointmentsModel.entityBeingEdited = await AppointmentsDBWorker.db.get(inAppointment.id!);

    if(appointmentsModel.entityBeingEdited.apptDate == null) {appointmentsModel.setChosenDate("");}
    else {
      List dateParts = appointmentsModel.entityBeingEdited.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
      appointmentsModel.setChosenDate(DateFormat("dd/MM/yyyy", "pt_BR").format(apptDate.toLocal()));
    }

    if(!inContext.mounted) return;

    if(appointmentsModel.entityBeingEdited.apptTime == null) {appointmentsModel.setApptTime("");}
    else {
      List timeParts = appointmentsModel.entityBeingEdited.apptTime.split(",");
      TimeOfDay apptTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      appointmentsModel.setApptTime(apptTime.format(inContext));
    }

    appointmentsModel.setStackIndex(1);

    Navigator.pop(inContext);
  }

  Future _deleteAppointment(BuildContext inContext, Appointment inAppointment) async {
    return showDialog(
      context: inContext,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: Text("Apagar compromisso"),
          content: Text("Quer excluir ${inAppointment.description}?", style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {Navigator.of(inAlertContext).pop();}
            ),

            TextButton(
              child: Text("Apagar"),
              onPressed: () async {
                await AppointmentsDBWorker.db.delete(inAppointment.id!);

                if(!inAlertContext.mounted) return;
                Navigator.of(inAlertContext).pop();

                ScaffoldMessenger.of(inContext).showSnackBar(
                  SnackBar(
                    content: Text("Compromisso excluído!"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red
                  )
                );

                appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
              }
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    EventList<Event> markedDateMap = EventList(events: {});
    
    for(int i = 0; i < appointmentsModel.entityList.length; i++) {
      Appointment appointment = appointmentsModel.entityList[i];
      List dateParts = appointment.apptDate!.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));

      markedDateMap.add(
        apptDate,
        Event(
          date: apptDate,
          icon: Container(decoration: const BoxDecoration(color: Colors.blue))
        )
      );
    }

    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget? inChild, AppointmentsModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              shape: CircleBorder(),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();

                DateTime now = DateTime.now();
                appointmentsModel.entityBeingEdited.apptDate = "${now.year}, ${now.month}, ${now.day}";
                appointmentsModel.setChosenDate(DateFormat("dd/MM/yyyy", "pt_BR").format(now.toLocal()));
                appointmentsModel.setApptTime("");
                appointmentsModel.setStackIndex(1);
              }
            ),

            body: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: CalendarCarousel<Event>(
                      thisMonthDayBorderColor: Colors.grey,
                      daysHaveCircularBorder: true,
                      markedDatesMap: markedDateMap,
                      locale: "pt",
                      onDayPressed: (DateTime inDate, List<Event> inEvents) {_showAppointments(inDate, inContext);}
                    )
                  )
                )
              ]
            )
          );
        }
      )
    );
  }
}