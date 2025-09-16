import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../models/upcycling_project.dart';
import '../models/device_passport.dart';
import '../models/device_diagnosis.dart';
import '../providers/upcycling_provider.dart';
import '../providers/diagnosis_provider.dart';
import '../services/ai_upcycling_service.dart';

class UpcyclingWorkspaceScreen extends StatefulWidget {
  const UpcyclingWorkspaceScreen({super.key});

  @override
  State<UpcyclingWorkspaceScreen> createState() =>
      _UpcyclingWorkspaceScreenState();
}

class _UpcyclingWorkspaceScreenState extends State<UpcyclingWorkspaceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UpcyclingProvider>().loadProjects();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Add the TabBar to the body
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'My Projects', icon: Icon(LucideIcons.palette)),
              Tab(text: 'Explore', icon: Icon(LucideIcons.search)),
              Tab(text: 'Materials', icon: Icon(LucideIcons.wrench)),
            ],
          ),
          // Search bar (only show on explore tab)
          if (_tabController.index == 1) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  prefixIcon: const Icon(LucideIcons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x),
                          onPressed: () {
                            _searchController.clear();
                            context.read<UpcyclingProvider>().searchProjects(
                              '',
                            );
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                onChanged: (value) {
                  context.read<UpcyclingProvider>().searchProjects(value);
                },
              ),
            ),
          ],

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyProjectsTab(),
                _buildExploreTab(),
                _buildMaterialsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateProjectDialog(context),
        tooltip: 'Generate AI Project Ideas',
        child: Icon(LucideIcons.wand),
      ),
    );
  }

  Widget _buildMyProjectsTab() {
    return Consumer<UpcyclingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final projects = provider.userProjects;

        if (projects.isEmpty) {
          return _buildEmptyState(
            'No projects yet',
            'Start your first upcycling project with AI assistance!',
            LucideIcons.palette,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            return _buildProjectCard(projects[index]);
          },
        );
      },
    );
  }

  Widget _buildExploreTab() {
    return Consumer<UpcyclingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final projects = provider.publicProjects;

        if (projects.isEmpty) {
          return _buildEmptyState(
            'No public projects',
            'Be the first to share your upcycling project!',
            LucideIcons.search,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadProjects(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return _buildExploreProjectCard(projects[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMaterialsTab() {
    return Consumer<UpcyclingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Material Sourcing Guide',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Find sustainable materials for your upcycling projects:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              _buildMaterialCategory(
                'Recycled Electronics',
                [
                  'Circuit boards from old devices',
                  'Wires and connectors',
                  'Plastic casings',
                  'Batteries (handle with care)',
                ],
                LucideIcons.cpu,
                Colors.blue,
              ),

              const SizedBox(height: 16),

              _buildMaterialCategory(
                'Household Items',
                [
                  'Wood scraps from furniture',
                  'Glass jars and bottles',
                  'Fabric scraps',
                  'Metal containers',
                ],
                LucideIcons.house,
                Colors.green,
              ),

              const SizedBox(height: 16),

              _buildMaterialCategory(
                'Art Supplies',
                [
                  'Acrylic paints',
                  'Wood stain',
                  'Sandpaper',
                  'Glue and adhesives',
                ],
                LucideIcons.brush,
                Colors.purple,
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 Pro Tips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTipItem(
                        'Check local recycling centers for free materials',
                      ),
                      _buildTipItem(
                        'Join maker communities to share and trade materials',
                      ),
                      _buildTipItem(
                        'Look for "free" sections on local classifieds',
                      ),
                      _buildTipItem(
                        'Partner with local businesses for material donations',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(UpcyclingProject project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showProjectDetails(context, project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.status.toString().split('.').last,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.difficulty.toString().split('.').last,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(LucideIcons.clock, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${project.estimatedHours}h',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    LucideIcons.dollarSign,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₱${project.estimatedCost.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: project.completionPercentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(project.status),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${project.completedSteps}/${project.totalSteps} steps completed',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showProjectSteps(context, project),
                    icon: const Icon(LucideIcons.listChecks, size: 16),
                    label: const Text('Steps'),
                  ),
                  const SizedBox(width: 8),
                  if (project.status != ProjectStatus.completed)
                    TextButton.icon(
                      onPressed: () => _updateProjectStatus(context, project),
                      icon: Icon(LucideIcons.check, size: 16),
                      label: const Text('Update'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreProjectCard(UpcyclingProject project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showProjectDetails(context, project),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.grey[400]),
                    onPressed: () {
                      context.read<UpcyclingProvider>().likeProject(project.id);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(LucideIcons.user, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'By ${project.creatorId}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(LucideIcons.clock, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${project.estimatedHours}h',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(project.difficulty),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.difficulty.toString().split('.').last,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(LucideIcons.eye, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${project.viewsCount ?? 0}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Icon(LucideIcons.heart, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${project.likesCount ?? 0}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCategory(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(LucideIcons.check, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateProjectDialog(context),
            icon: Icon(LucideIcons.wand),
            label: const Text('Generate Ideas'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.grey;
      case ProjectStatus.inProgress:
        return Colors.blue;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.paused:
        return Colors.orange;
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.blue;
      case DifficultyLevel.advanced:
        return Colors.orange;
      case DifficultyLevel.expert:
        return Colors.red;
    }
  }

  void _showCreateProjectDialog(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(context, listen: false);
    final upcyclingProvider = Provider.of<UpcyclingProvider>(context, listen: false);

    // Check if we have diagnosis data
    if (diagnosisProvider.currentResult == null) {
      _showNoDiagnosisDialog(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _AIProjectGeneratorDialog(
        diagnosisResult: diagnosisProvider.currentResult!,
        upcyclingProvider: upcyclingProvider,
      ),
    );
  }

  void _showNoDiagnosisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Device Diagnosis'),
        content: const Text(
          'You need to diagnose a device first before generating upcycling ideas. Please go to the home screen and diagnose your device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/main');
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  void _showProjectDetails(BuildContext context, UpcyclingProject project) {
    // Implementation for showing project details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(project.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Difficulty: ${project.difficulty.toString().split('.').last}',
            ),
            Text('Time: ${project.estimatedHours} hours'),
            Text('Cost: ₱${project.estimatedCost.toStringAsFixed(0)}'),
            Text('Status: ${project.status.toString().split('.').last}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement view full project
              Navigator.of(context).pop();
            },
            child: const Text('View Project'),
          ),
        ],
      ),
    );
  }

  void _showProjectSteps(BuildContext context, UpcyclingProject project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${project.title} - Steps'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: project.steps.length,
            itemBuilder: (context, index) {
              final step = project.steps[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: step.isCompleted
                      ? Colors.green
                      : Colors.grey[300],
                  child: step.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text('${step.stepNumber}'),
                ),
                title: Text(step.title),
                subtitle: Text(step.description),
                trailing: step.isCompleted
                    ? null
                    : IconButton(
                        icon: const Icon(LucideIcons.check),
                        onPressed: () {
                          context.read<UpcyclingProvider>().updateProjectStep(
                            project.id,
                            step.stepNumber,
                            true,
                            null,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateProjectStatus(BuildContext context, UpcyclingProject project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Project Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Mark as In Progress'),
              leading: const Icon(LucideIcons.play),
              onTap: () {
                context.read<UpcyclingProvider>().updateProjectStatus(
                  project.id,
                  ProjectStatus.inProgress,
                );
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Mark as Completed'),
              leading: Icon(LucideIcons.check),
              onTap: () {
                context.read<UpcyclingProvider>().updateProjectStatus(
                  project.id,
                  ProjectStatus.completed,
                );
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Pause Project'),
              leading: const Icon(LucideIcons.pause),
              onTap: () {
                context.read<UpcyclingProvider>().updateProjectStatus(
                  project.id,
                  ProjectStatus.paused,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AIProjectGeneratorDialog extends StatefulWidget {
  final DiagnosisResult diagnosisResult;
  final UpcyclingProvider upcyclingProvider;

  const _AIProjectGeneratorDialog({
    required this.diagnosisResult,
    required this.upcyclingProvider,
  });

  @override
  State<_AIProjectGeneratorDialog> createState() => _AIProjectGeneratorDialogState();
}

class _AIProjectGeneratorDialogState extends State<_AIProjectGeneratorDialog> {
  List<ProjectIdea> _ideas = [];
  bool _isGenerating = false;
  bool _isCreatingProject = false;
  String? _error;
  ProjectIdea? _selectedIdea;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('AI Project Generator'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device: ${widget.diagnosisResult.deviceModel}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Screen: ${widget.diagnosisResult.deviceHealth.screenCondition.name}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Battery: ${widget.diagnosisResult.deviceHealth.batteryHealth.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Hardware: ${widget.diagnosisResult.deviceHealth.hardwareCondition.name}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_isGenerating) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating creative ideas...'),
                  ],
                ),
              ),
            ] else if (_ideas.isEmpty) ...[
              const Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.wand, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Generate personalized upcycling ideas\nbased on your device diagnosis',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text(
                'Generated Ideas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _ideas.length,
                  itemBuilder: (context, index) {
                    final idea = _ideas[index];
                    final isSelected = _selectedIdea == idea;
                    return Card(
                      color: isSelected ? Colors.blue[50] : null,
                      child: ListTile(
                        title: Text(
                          idea.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              idea.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(
                                  label: Text(
                                    idea.difficulty.name,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  backgroundColor: _getDifficultyColor(idea.difficulty),
                                  labelStyle: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₱${idea.estimatedCost.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Materials: ${idea.materials.take(3).join(", ")}${idea.materials.length > 3 ? "..." : ""}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            _selectedIdea = isSelected ? null : idea;
                          });
                        },
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_ideas.isEmpty && !_isGenerating)
          ElevatedButton(
            onPressed: _generateIdeas,
            child: const Text('Generate Ideas'),
          ),
        if (_selectedIdea != null && !_isCreatingProject)
          ElevatedButton(
            onPressed: _createProject,
            child: const Text('Create Project'),
          ),
        if (_isCreatingProject)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Future<void> _generateIdeas() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      // Create a temporary DevicePassport from diagnosis data
      final devicePassport = DevicePassport(
        id: 'temp',
        userId: 'current_user',
        deviceModel: widget.diagnosisResult.deviceModel,
        manufacturer: 'Unknown', // Would be better to get this from diagnosis
        yearOfRelease: DateTime.now().year - 2, // Estimate
        operatingSystem: 'Android', // Default assumption
        imageUrls: widget.diagnosisResult.imageUrls,
        lastDiagnosis: widget.diagnosisResult,
      );

      final ideas = await widget.upcyclingProvider.generateProjectIdeas(devicePassport);

      setState(() {
        _ideas = ideas;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate ideas: $e';
        _isGenerating = false;
      });
    }
  }

  Future<void> _createProject() async {
    if (_selectedIdea == null) return;

    setState(() {
      _isCreatingProject = true;
    });

    try {
      final devicePassport = DevicePassport(
        id: 'temp',
        userId: 'current_user',
        deviceModel: widget.diagnosisResult.deviceModel,
        manufacturer: 'Unknown',
        yearOfRelease: DateTime.now().year - 2,
        operatingSystem: 'Android',
        imageUrls: widget.diagnosisResult.imageUrls,
        lastDiagnosis: widget.diagnosisResult,
      );

      final project = await widget.upcyclingProvider.createProject(
        devicePassport: devicePassport,
        projectIdea: _selectedIdea!.title,
        difficulty: _selectedIdea!.difficulty,
        creatorId: 'current_user',
      );

      if (project != null && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.title}" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to create project: $e';
        _isCreatingProject = false;
      });
    }
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
      case DifficultyLevel.expert:
        return Colors.purple;
    }
  }
}
