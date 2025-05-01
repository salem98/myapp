// Follow this setup guide to integrate the Deno runtime into your application:
// https://deno.com/manual/examples/supabase-functions

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type"
};

// Helper function to sanitize and validate data
function sanitizeData(data) {
  // Create a new object with sanitized values
  const sanitized = {};
  
  // Basic text fields - trim and ensure they're strings
  ['name', 'email', 'phone', 'company', 'businessType', 'country', 'additionalInfo', 'contactMethod'].forEach(field => {
    sanitized[field] = data[field] ? String(data[field]).trim() : '';
  });
  
  // Convert monthlyShipments to number or default to 0
  sanitized.monthlyShipments = data.monthlyShipments ? 
    (typeof data.monthlyShipments === 'number' ? 
      data.monthlyShipments : 
      parseInt(String(data.monthlyShipments).replace(/[^0-9]/g, ''), 10) || 0) : 
    0;
  
  return sanitized;
}

// Helper function to determine package type
function determinePackageType(businessType) {
  const typeMap = {
    'E-commerce': 'small',
    'Manufacturing': 'large',
    'Retail': 'medium'
  };
  
  return typeMap[businessType] || 'custom';
}

// Helper function to determine shipping method
function determineShippingMethod(country) {
  return ['Singapore', 'Malaysia'].includes(country) ? 'air' : 'sea';
}

// Helper function to get country code
function getCountryCode(country) {
  const codeMap = {
    'Singapore': 'SG',
    'Malaysia': 'MY',
    'Taiwan': 'TW',
    'Dubai': 'AE'
  };
  
  return codeMap[country] || 'XX';
}

// Helper function to send email
async function sendEmail(data, leadId, refNumber, leadCount) {
  try {
    // Resend API key
    const RESEND_API_KEY = "re_eqoXawur_MYZz4vc5RdvGMqSJGpbb4Q4p";
    const notificationEmail = "nathan@chosing.vn";
    
    console.log("Attempting to send email via Resend API");
    
    // Build email content
    const subject = `New Shipping Lead #${leadCount !== null ? leadCount + 1 : 'N/A'}: ${data.country} Quote Request`;
    const htmlContent = `
      <h2>New Shipping Quote Request</h2>
      <p>A new lead has been submitted through the app:</p>

      <h3>Contact Information:</h3>
      <ul>
        <li><strong>Name:</strong> ${data.name}</li>
        <li><strong>Email:</strong> ${data.email}</li>
        <li><strong>Phone:</strong> ${data.phone}</li>
        <li><strong>Company:</strong> ${data.company}</li>
      </ul>

      <h3>Business Details:</h3>
      <ul>
        <li><strong>Business Type:</strong> ${data.businessType}</li>
        <li><strong>Country:</strong> ${data.country}</li>
        <li><strong>Package Type:</strong> ${determinePackageType(data.businessType)}</li>
        <li><strong>Shipping Method:</strong> ${determineShippingMethod(data.country)}</li>
        <li><strong>Monthly Shipments:</strong> ${data.monthlyShipments || "Not specified"}</li>
      </ul>

      <h3>Additional Information:</h3>
      <p>${data.additionalInfo || "None provided"}</p>

      <p>This lead was submitted on ${new Date().toLocaleString()} and has been saved to the database with ID: ${leadId || 'N/A'}</p>
      <p><strong>Reference Number:</strong> ${refNumber}</p>
      <p><strong>Total Leads Count:</strong> ${leadCount !== null ? leadCount + 1 : 'N/A'}</p>
    `;
    
    // Send email using Resend API
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`
      },
      body: JSON.stringify({
        from: 'TNS Express <onboarding@resend.dev>',
        to: notificationEmail,
        subject: subject,
        html: htmlContent
      })
    });
    
    const emailResponse = await res.json();
    console.log("Email sent via Resend API:", emailResponse);
    return { success: true, data: emailResponse };
  } catch (error) {
    console.error("Error sending email via Resend API:", error);
    return { success: false, error };
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  
  try {
    // Only allow POST requests
    if (req.method !== "POST") {
      return new Response(JSON.stringify({
        error: "Method not allowed"
      }), {
        status: 405,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    
    // Get the request body
    let formData;
    try {
      formData = await req.json();
      console.log("Received form data:", JSON.stringify(formData));
    } catch (parseError) {
      console.error("Error parsing request body:", parseError);
      return new Response(JSON.stringify({
        error: "Invalid JSON in request body"
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    
    // Sanitize and validate the data
    const sanitizedData = sanitizeData(formData);
    console.log("Sanitized data:", JSON.stringify(sanitizedData));
    
    // Validate required fields
    const requiredFields = ['name', 'email', 'phone', 'company', 'country'];
    const missingFields = requiredFields.filter((field) => !sanitizedData[field]);
    
    if (missingFields.length > 0) {
      return new Response(JSON.stringify({
        error: `Missing required fields: ${missingFields.join(', ')}`
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    
    // Create a Supabase client
    let supabase;
    try {
      const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
      const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
      
      if (!supabaseUrl || !supabaseServiceKey) {
        throw new Error("Missing Supabase environment variables");
      }
      
      supabase = createClient(supabaseUrl, supabaseServiceKey);
    } catch (clientError) {
      console.error("Error creating Supabase client:", clientError);
      
      // Generate a fallback reference number
      const fallbackRefNumber = `EST${new Date().getTime().toString().substring(5, 13)}`;
      
      // Try to send email as fallback
      const emailResult = await sendEmail(sanitizedData, null, fallbackRefNumber, null);
      
      // Return a partial success response
      return new Response(JSON.stringify({
        success: true,
        message: "Lead submitted via email only (database unavailable)",
        referenceNumber: fallbackRefNumber,
        emailSent: emailResult.success
      }), {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    
    // Get the total count of leads
    let leadCount = null;
    try {
      const { count, error: countError } = await supabase
        .from("shipping_leads")
        .select("*", { count: "exact", head: true });
      
      if (!countError) {
        leadCount = count;
      } else {
        console.error("Error getting lead count:", countError);
      }
    } catch (countError) {
      console.error("Exception getting lead count:", countError);
    }
    
    // Determine package type based on business type
    const packageType = determinePackageType(sanitizedData.businessType);
    
    // Determine shipping method based on country
    const shippingMethod = determineShippingMethod(sanitizedData.country);
    
    // Get country code
    const countryCode = getCountryCode(sanitizedData.country);
    
    // Generate reference number
    const refNumber = `EST${new Date().getTime().toString().substring(5, 13)}`;
    
    // Store the lead in the database
    let lead = null;
    let insertError = null;
    
    try {
      const result = await supabase
        .from("shipping_leads")
        .insert({
          name: sanitizedData.name,
          email: sanitizedData.email,
          phone: sanitizedData.phone,
          company: sanitizedData.company,
          business_type: sanitizedData.businessType,
          country: countryCode,
          country_name: sanitizedData.country,
          package_type: packageType,
          shipping_method: shippingMethod,
          monthly_shipments: sanitizedData.monthlyShipments,
          additional_info: sanitizedData.additionalInfo,
          status: "NEW",
          reference_number: refNumber
        })
        .select()
        .single();
      
      if (result.error) {
        insertError = result.error;
        console.error("Error inserting lead:", insertError);
      } else {
        lead = result.data;
      }
    } catch (dbError) {
      insertError = dbError;
      console.error("Exception inserting lead:", dbError);
    }
    
    // If database insertion failed, try to send email as fallback
    if (insertError) {
      // Try to send email as fallback
      const emailResult = await sendEmail(sanitizedData, null, refNumber, leadCount);
      
      // If email was sent successfully, return a partial success
      if (emailResult.success) {
        return new Response(JSON.stringify({
          success: true,
          message: "Lead submitted via email only (database error)",
          referenceNumber: refNumber,
          emailSent: true,
          dbError: insertError.message
        }), {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json"
          }
        });
      }
      
      // Both database and email failed
      return new Response(JSON.stringify({
        error: "Failed to save lead information",
        details: insertError.message
      }), {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    
    // Send email notification
    const emailResult = await sendEmail(sanitizedData, lead.id, refNumber, leadCount);
    
    // Return success response
    return new Response(JSON.stringify({
      success: true,
      message: "Lead submitted successfully",
      leadId: lead.id,
      referenceNumber: refNumber,
      emailSent: emailResult.success
    }), {
      status: 200,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
    
  } catch (error) {
    console.error("Unexpected error:", error);
    
    return new Response(JSON.stringify({
      error: "An unexpected error occurred",
      details: error.message
    }), {
      status: 500,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
  }
});