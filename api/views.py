from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from agent_manager import get_or_create_agent, end_session, get_message_list

@api_view(['GET'])
def hello(request):
    return Response({"message": "Hello from Grammo!"})


@api_view(['POST'])
def chat(request):
	"""Start or continue an existing chat session."""
	message = request.data.get("message")
	chat_session = request.data.get("chatSession")

	if not message:
		return Response({
			"status": "error",
			"response": "Invalid message."
		}, status=status.HTTP_400_BAD_REQUEST)

	agent = get_or_create_agent(request.session, chat_session)

	mode = request.data.get("mode")
	tone = request.data.get("tone")
	messages = get_message_list(mode, tone, message)

	result = agent.invoke({ "messages": messages },
		config={ "configurable": {"thread_id": request.session.session_key } }
	)

	last_message = result.get('messages', [])[-1] if result.get('messages') else None

	if not (last_message and hasattr(last_message, 'content') and last_message.content):
		return Response({
			"status": "error",
			"response": "Server Error"
		}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

	return Response({
		"status": "success",
		"response": last_message.content
	}, status=status.HTTP_200_OK)


@api_view(['POST'])
def end(request):
    """End and delete the chat session."""
    if end_session(request.session):
        request.session.flush()
        return Response({"status": "success", "message": "Session ended successfully"})

    return Response({
        "status": "error",
        "response": "No active session."
    }, status=status.HTTP_404_NOT_FOUND)


def handler404(request, exception):
    """Custom 404 handler that returns JSON response."""
    return Response({
        "status": "error",
        "response": "Not found"
    }, status=status.HTTP_404_NOT_FOUND)

