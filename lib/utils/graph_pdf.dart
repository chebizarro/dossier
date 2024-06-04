import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/graph.dart';
import '../models/node.dart';
import '../models/edge.dart';

class GraphPdf {
  final Graph graph;

  GraphPdf(this.graph);

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              width: double.infinity,
              height: double.infinity,
              child: _buildGraph(),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildGraph() {
    return pw.Stack(
      children: [
        ...graph.edges.map((edge) => _buildEdge(edge)),
        ...graph.nodes.map((node) => _buildNode(node)),
      ],
    );
  }

  pw.Widget _buildNode(Node node) {
    return pw.Positioned(
      left: node.x,
      top: node.y,
      child: pw.Column(
        children: [
          pw.Container(
            width: 48,
            height: 48,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(node.nodeType.color.value),
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                node.nodeType.label,
                style: pw.TextStyle(color: PdfColor.fromInt(Colors.white.value)),
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(node.label),
        ],
      ),
    );
  }

  pw.Widget _buildEdge(Edge edge) {
    final fromNode = graph.nodes.firstWhere((node) => node.id == edge.fromNodeId);
    final toNode = graph.nodes.firstWhere((node) => node.id == edge.toNodeId);

    return pw.CustomPaint(
      painter: (PdfGraphics canvas, PdfPoint size) {
        final fromOffset = PdfPoint(fromNode.x + 24, fromNode.y + 24);
        final toOffset = PdfPoint(toNode.x + 24, toNode.y + 24);

        canvas
          ..setStrokeColor(PdfColors.black)
          ..setLineWidth(2)
          ..moveTo(fromOffset.x, fromOffset.y)
          ..lineTo(toOffset.x, toOffset.y)
          ..strokePath();
      },
    );
  }
}
