from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from agent_manager import get_or_create_agent, end_session, get_message_list
from django.conf import settings

@csrf_exempt
@permission_classes([AllowAny])
@api_view(['GET'])
def hello(request):
    return Response({"message": "Hello from Grammo!"})

@csrf_exempt
@permission_classes([AllowAny])
@api_view(['POST'])
def chat(request):
	"""Start or continue an existing chat session."""
	# Prefer secure HttpOnly cookie for session tracking
	cookie_session = request.COOKIES.get("gm_session")
	message = request.data.get("message")

	if not message:
		return Response({
			"status": "error",
			"response": "Invalid message."
		}, status=status.HTTP_400_BAD_REQUEST)

	# Use cookie if present; otherwise create a new session
	agent, session_key = get_or_create_agent(cookie_session)

	mode = request.data.get("mode")
	tone = request.data.get("tone")
	messages = get_message_list(mode, tone, message)

	result = agent.invoke({ "messages": messages },
		config={ "configurable": {"thread_id": session_key } }
	)

	last_message = result.get('messages', [])[-1] if result.get('messages') else None

	if not (last_message and hasattr(last_message, 'content') and last_message.content):
		return Response({
			"status": "error",
			"response": "Server Error"
		}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

	resp = Response({
		"status": "success",
		"response": last_message.content
	}, status=status.HTTP_200_OK)

	# If cookie was missing, set it now with secure attributes
	if not cookie_session:
		secure = True if settings.MODE == 'production' else False
		samesite = 'None' if settings.MODE == 'production' else 'Lax'
		resp.set_cookie(
			"gm_session",
			value=session_key,
			httponly=True,
			secure=secure,
			samesite=samesite,
			max_age=60 * 60 * 24
		)

	return resp

@csrf_exempt
@permission_classes([AllowAny])
@api_view(['POST'])
def end(request):
    """End and delete the chat session."""
    cookie_session = request.COOKIES.get("gm_session")
    if end_session(cookie_session):
        resp = Response({"status": "success", "message": "Session ended successfully"})
        # Clear cookie
        resp.delete_cookie("gm_session")
        return resp
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

