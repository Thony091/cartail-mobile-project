class AdminTicketDraft {
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final int? serviceId;
  final String serviceName;
  final String clientName;
  final String clientEmail;
  final String clientRut;
  final String priority;

  const AdminTicketDraft({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.serviceId,
    required this.serviceName,
    required this.clientName,
    required this.clientEmail,
    required this.clientRut,
    required this.priority,
  });

  AdminTicketDraft copyWith({
    String? title,
    String? description,
    String? startDate,
    String? endDate,
    int? serviceId,
    String? serviceName,
    String? clientName,
    String? clientEmail,
    String? clientRut,
    String? priority,
  }) {
    return AdminTicketDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientRut: clientRut ?? this.clientRut,
      priority: priority ?? this.priority,
    );
  }
}
